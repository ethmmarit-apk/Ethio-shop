const admin = require('firebase-admin');
const { logger } = require('../utils/logger');
const path = require('path');

class FirebaseService {
  constructor() {
    this.admin = null;
    this.auth = null;
    this.firestore = null;
    this.storage = null;
    this.messaging = null;
    this.isInitialized = false;
  }

  async initialize() {
    try {
      if (this.isInitialized) {
        logger.info('⚠️ Firebase already initialized');
        return;
      }

      // Get service account path
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
      if (!serviceAccountPath) {
        throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH is not set in environment variables');
      }

      // Load service account
      let serviceAccount;
      try {
        serviceAccount = require(path.resolve(serviceAccountPath));
      } catch (error) {
        throw new Error(`Failed to load Firebase service account: ${error.message}`);
      }

      // Initialize Firebase Admin SDK
      this.admin = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET || 'ethio-shop-01525861.firebasestorage.app',
        databaseURL: process.env.FIREBASE_DATABASE_URL || 'https://ethio-shop-01525861.firebaseio.com',
      });

      // Initialize services
      this.auth = this.admin.auth();
      this.firestore = this.admin.firestore();
      this.storage = this.admin.storage();
      this.messaging = this.admin.messaging();

      // Configure Firestore settings
      this.firestore.settings({
        timestampsInSnapshots: true,
        ignoreUndefinedProperties: true,
      });

      // Configure storage
      this.storage.bucket();

      this.isInitialized = true;
      logger.info('✅ Firebase Admin SDK initialized successfully');
      logger.debug(`Firebase Project: ${serviceAccount.project_id}`);
      logger.debug(`Storage Bucket: ${process.env.FIREBASE_STORAGE_BUCKET}`);

    } catch (error) {
      logger.error('❌ Failed to initialize Firebase:', error);
      throw error;
    }
  }

  // Authentication methods
  async createUser(userData) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const userRecord = await this.auth.createUser({
        email: userData.email,
        emailVerified: false,
        phoneNumber: userData.phone,
        password: userData.password,
        displayName: `${userData.firstName} ${userData.lastName}`,
        disabled: false,
        photoURL: userData.photoURL,
      });

      // Set custom claims for role-based access
      await this.auth.setCustomUserClaims(userRecord.uid, {
        role: userData.userType || 'buyer',
        verified: false,
        createdAt: Date.now(),
      });

      logger.debug(`✅ Firebase user created: ${userRecord.uid}`);
      return userRecord;
    } catch (error) {
      logger.error('❌ Firebase createUser error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async getUser(uid) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const userRecord = await this.auth.getUser(uid);
      return userRecord;
    } catch (error) {
      logger.error('❌ Firebase getUser error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async getUserByEmail(email) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const userRecord = await this.auth.getUserByEmail(email);
      return userRecord;
    } catch (error) {
      logger.error('❌ Firebase getUserByEmail error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async updateUser(uid, userData) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const userRecord = await this.auth.updateUser(uid, userData);
      logger.debug(`✅ Firebase user updated: ${uid}`);
      return userRecord;
    } catch (error) {
      logger.error('❌ Firebase updateUser error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async deleteUser(uid) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      await this.auth.deleteUser(uid);
      logger.debug(`✅ Firebase user deleted: ${uid}`);
      return true;
    } catch (error) {
      logger.error('❌ Firebase deleteUser error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async verifyIdToken(idToken) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const decodedToken = await this.auth.verifyIdToken(idToken, true);
      return decodedToken;
    } catch (error) {
      logger.error('❌ Firebase verifyIdToken error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async createCustomToken(uid, additionalClaims = {}) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const token = await this.auth.createCustomToken(uid, additionalClaims);
      return token;
    } catch (error) {
      logger.error('❌ Firebase createCustomToken error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  // Firestore methods
  async createDocument(collection, data, id = null) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const docRef = id 
        ? this.firestore.collection(collection).doc(id)
        : this.firestore.collection(collection).doc();
      
      await docRef.set({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      logger.debug(`✅ Firestore document created: ${collection}/${docRef.id}`);
      return docRef.id;
    } catch (error) {
      logger.error('❌ Firestore createDocument error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async getDocument(collection, id) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const docRef = this.firestore.collection(collection).doc(id);
      const doc = await docRef.get();
      
      if (!doc.exists) {
        return null;
      }
      
      return { id: doc.id, ...doc.data() };
    } catch (error) {
      logger.error('❌ Firestore getDocument error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async updateDocument(collection, id, data) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const docRef = this.firestore.collection(collection).doc(id);
      await docRef.update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      logger.debug(`✅ Firestore document updated: ${collection}/${id}`);
      return true;
    } catch (error) {
      logger.error('❌ Firestore updateDocument error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async deleteDocument(collection, id) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const docRef = this.firestore.collection(collection).doc(id);
      await docRef.delete();
      
      logger.debug(`✅ Firestore document deleted: ${collection}/${id}`);
      return true;
    } catch (error) {
      logger.error('❌ Firestore deleteDocument error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async queryDocuments(collection, conditions = [], limit = 50) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      let query = this.firestore.collection(collection);
      
      // Apply conditions
      conditions.forEach((condition) => {
        query = query.where(condition.field, condition.operator, condition.value);
      });
      
      // Apply limit
      query = query.limit(limit);
      
      const snapshot = await query.get();
      const documents = [];
      
      snapshot.forEach((doc) => {
        documents.push({ id: doc.id, ...doc.data() });
      });
      
      return documents;
    } catch (error) {
      logger.error('❌ Firestore queryDocuments error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  // Storage methods
  async uploadFile(fileBuffer, fileName, folder = 'uploads') {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const filePath = `${folder}/${Date.now()}_${fileName}`;
      const file = this.storage.bucket().file(filePath);
      
      await file.save(fileBuffer, {
        metadata: {
          contentType: this.getContentType(fileName),
          metadata: {
            uploadedAt: new Date().toISOString(),
            originalName: fileName,
          },
        },
      });

      // Make file publicly accessible
      await file.makePublic();

      const publicUrl = `https://storage.googleapis.com/${this.storage.bucket().name}/${filePath}`;
      
      logger.debug(`✅ File uploaded: ${publicUrl}`);
      return {
        url: publicUrl,
        path: filePath,
        name: fileName,
        size: fileBuffer.length,
      };
    } catch (error) {
      logger.error('❌ Firebase Storage upload error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async deleteFile(fileUrl) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const filePath = this.getFilePathFromUrl(fileUrl);
      const file = this.storage.bucket().file(filePath);
      await file.delete();
      
      logger.debug(`✅ File deleted: ${filePath}`);
      return true;
    } catch (error) {
      logger.error('❌ Firebase Storage delete error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async getFileMetadata(fileUrl) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

    try {
      const filePath = this.getFilePathFromUrl(fileUrl);
      const file = this.storage.bucket().file(filePath);
      const [metadata] = await file.getMetadata();
      
      return metadata;
    } catch (error) {
      logger.error('❌ Firebase Storage getMetadata error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  // Messaging methods
  async sendPushNotification(token, title, body, data = {}) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

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
            icon: 'ic_notification',
            color: '#4CAF50',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              contentAvailable: true,
            },
          },
        },
        webpush: {
          headers: {
            Urgency: 'high',
          },
        },
      };

      const response = await this.messaging.send(message);
      logger.debug(`✅ Push notification sent: ${response}`);
      return response;
    } catch (error) {
      logger.error('❌ Firebase Messaging error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  async sendMulticastNotification(tokens, title, body, data = {}) {
    if (!this.isInitialized) {
      throw new Error('Firebase not initialized');
    }

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
      logger.debug(`✅ Multicast notification sent: ${response.successCount} successful, ${response.failureCount} failed`);
      return response;
    } catch (error) {
      logger.error('❌ Firebase Multicast Messaging error:', error);
      throw this.handleFirebaseError(error);
    }
  }

  // Helper methods
  getContentType(fileName) {
    const extension = fileName.toLowerCase().split('.').pop();
    const contentTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'txt': 'text/plain',
      'json': 'application/json',
      'csv': 'text/csv',
    };
    
    return contentTypes[extension] || 'application/octet-stream';
  }

  getFilePathFromUrl(url) {
    const baseUrl = `https://storage.googleapis.com/${this.storage.bucket().name}/`;
    return url.replace(baseUrl, '');
  }

  handleFirebaseError(error) {
    // Map Firebase errors to user-friendly messages
    const errorMap = {
      'auth/email-already-exists': 'Email already exists',
      'auth/invalid-email': 'Invalid email address',
      'auth/phone-number-already-exists': 'Phone number already exists',
      'auth/invalid-phone-number': 'Invalid phone number',
      'auth/uid-already-exists': 'User ID already exists',
      'auth/user-not-found': 'User not found',
      'auth/wrong-password': 'Incorrect password',
      'auth/too-many-requests': 'Too many requests, try again later',
      'auth/network-request-failed': 'Network error, please check your connection',
      'storage/unauthorized': 'Unauthorized access to storage',
      'storage/object-not-found': 'File not found',
      'storage/quota-exceeded': 'Storage quota exceeded',
    };

    const message = errorMap[error.code] || error.message;
    const customError = new Error(message);
    customError.code = error.code;
    customError.originalError = error;
    
    return customError;
  }

  async healthCheck() {
    try {
      // Test authentication
      await this.auth.listUsers(1);
      
      // Test firestore
      const testRef = this.firestore.collection('_healthcheck').doc('test');
      await testRef.set({ timestamp: admin.firestore.FieldValue.serverTimestamp() });
      await testRef.delete();
      
      // Test storage
      const bucket = this.storage.bucket();
      const [files] = await bucket.getFiles({ maxResults: 1 });
      
      return {
        status: 'healthy',
        auth: 'OK',
        firestore: 'OK',
        storage: 'OK',
        messaging: 'OK',
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message,
        details: 'Firebase services check failed',
      };
    }
  }

  async close() {
    if (this.admin) {
      await this.admin.delete();
      this.isInitialized = false;
      logger.info('✅ Firebase connections closed');
    }
  }
}

// Singleton instance
const firebaseService = new FirebaseService();

// Export helper functions
const initializeFirebase = async () => {
  return await firebaseService.initialize();
};

const getFirebaseService = () => {
  return firebaseService;
};

const closeFirebase = async () => {
  return await firebaseService.close();
};

module.exports = {
  firebaseService,
  initializeFirebase,
  getFirebaseService,
  closeFirebase,
  // Export common operations
  createUser: async (userData) => await firebaseService.createUser(userData),
  verifyIdToken: async (token) => await firebaseService.verifyIdToken(token),
  uploadFile: async (buffer, filename, folder) => await firebaseService.uploadFile(buffer, filename, folder),
  sendNotification: async (token, title, body, data) => await firebaseService.sendPushNotification(token, title, body, data),
  healthCheck: async () => await firebaseService.healthCheck(),
};