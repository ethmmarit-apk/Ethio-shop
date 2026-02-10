import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Authentication
  static FirebaseAuth get auth => _auth;
  
  // Storage
  static FirebaseStorage get storage => _storage;
  
  // Firestore
  static FirebaseFirestore get firestore => _firestore;
  
  // Messaging
  static FirebaseMessaging get messaging => _messaging;
  
  // Analytics
  static FirebaseAnalytics get analytics => _analytics;
  
  // Crashlytics
  static FirebaseCrashlytics get crashlytics => _crashlytics;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Sign in with email and password
  static Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with email and password
  static Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Upload image to Firebase Storage
  static Future<String> uploadImage(
    String path,
    String fileName,
    List<int> imageBytes,
  ) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Get FCM token for push notifications
  static Future<String?> getFCMToken() async {
    try {
      // Request permission for iOS
      await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      // Get token
      return await _messaging.getToken();
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  // Log event to Firebase Analytics
  static Future<void> logEvent(String name, [Map<String, dynamic>? params]) async {
    await _analytics.logEvent(
      name: name,
      parameters: params,
    );
  }

  // Record custom error to Crashlytics
  static Future<void> recordError(
    dynamic error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
    );
  }
}