const admin = require('firebase-admin');
const path = require('path');

class FirebaseService {
  constructor() {
    // Initialize Firebase Admin SDK
    if (!admin.apps.length) {
      const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    }
    
    this.auth = admin.auth();
    this.firestore = admin.firestore();
    this.storage = admin.storage();
    this.bucket = this.storage.bucket();
    this.messaging = admin.messaging();
  }

  // User Management
  async createUser(userData) {
    try {
      const user = await this.auth.createUser({
        email: userData.email,
        phoneNumber: userData.phone,
        password: userData.password,
        displayName: `${userData.firstName} ${userData.lastName}`,
        disabled: false,
      });

      // Set custom claims for role-based access
      await this.auth.setCustomUserClaims(user.uid, {
        role: userData.userType,
        verified: false,
      });

      return user;
    } catch (error) {
      throw new Error(`Failed to create user: ${error.message}`);
    }
  }

  async verifyIdToken(idToken) {
    try {
      const decodedToken = await this.auth.verifyIdToken(idToken);
      return decodedToken;
    } catch (error) {
      throw new Error(`Invalid ID token: ${error.message}`);
    }
  }

  async getUser(uid) {
    try {
      const user = await this.auth.getUser(uid);
      return user;
    } catch (error) {
      throw new Error(`User not found: ${error.message}`);
    }
  }

  // Firestore Operations
  async createDocument(collection, data, id = null) {
    try {
      const docRef = id 
        ? this.firestore.collection(collection).doc(id)
        : this.firestore.collection(collection).doc();
      
      await docRef.set({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (error) {
      throw new Error(`Failed to create document: ${error.message}`);
    }
  }

  async updateDocument(collection, id, data) {
    try {
      await this.firestore.collection(collection).doc(id).update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw new Error(`Failed to update document: ${error.message}`);
    }
  }

  // Storage Operations
  async uploadFile(fileBuffer, fileName, folder = 'uploads') {
    try {
      const filePath = `${folder}/${Date.now()}_${fileName}`;
      const file = this.bucket.file(filePath);
      
      await file.save(fileBuffer, {
        metadata: {
          contentType: this.getContentType(fileName),
        },
      });

      // Make file publicly accessible
      await file.makePublic();

      const publicUrl = `https://storage.googleapis.com/${this.bucket.name}/${filePath}`;
      return publicUrl;
    } catch (error) {
      throw new Error(`Failed to upload file: ${error.message}`);
    }
  }

  async deleteFile(fileUrl) {
    try {
      const filePath = this.getFilePathFromUrl(fileUrl);
      const file = this.bucket.file(filePath);
      await file.delete();
    } catch (error) {
      throw new Error(`Failed to delete file: ${error.message}`);
    }
  }

  // Push Notifications
  async sendPushNotification(token, title, body, data = {}) {
    try {
      const message = {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'marketplace_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      return response;
    } catch (error) {
      console.error('Failed to send notification:', error);
      throw error;
    }
  }

  async sendMulticastNotification(tokens, title, body, data = {}) {
    try {
      const message = {
        tokens: tokens,
        notification: {
          title: title,
          body: body,
        },
        data: data,
      };

      const response = await this.messaging.sendMulticast(message);
      return response;
    } catch (error) {
      console.error('Failed to send multicast notification:', error);
      throw error;
    }
  }

  // Helper Methods
  getContentType(fileName) {
    const extension = path.extname(fileName).toLowerCase();
    const contentTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.pdf': 'application/pdf',
      '.mp4': 'video/mp4',
      '.mp3': 'audio/mpeg',
    };
    
    return contentTypes[extension] || 'application/octet-stream';
  }

  getFilePathFromUrl(url) {
    const baseUrl = `https://storage.googleapis.com/${this.bucket.name}/`;
    return url.replace(baseUrl, '');
  }

  // Cleanup expired data
  async cleanupExpiredData(days = 30) {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - days);

      // Delete old notifications
      const notificationsSnapshot = await this.firestore
        .collection('notifications')
        .where('createdAt', '<', cutoffDate)
        .get();

      const batch = this.firestore.batch();
      notificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Cleaned up ${notificationsSnapshot.size} old notifications`);
    } catch (error) {
      console.error('Cleanup failed:', error);
    }
  }
}

module.exports = new FirebaseService();