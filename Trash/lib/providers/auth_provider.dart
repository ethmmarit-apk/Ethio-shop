import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _authToken;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get authToken => _authToken;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    _user = _firebaseAuth.currentUser;
    if (_user != null) {
      await _loadUserData();
    }
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _loadUserData();
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', _user!.uid);

    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } catch (e) {
      _error = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithPhone(String phone, String password) async {
    // Phone login implementation
    // This would involve Firebase phone authentication
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Create user document in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'uid': _user!.uid,
        'email': email,
        'phone': phone,
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'verificationStatus': 'pending',
        'rating': 0.0,
        'totalRatings': 0,
      });

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', _user!.uid);

    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } catch (e) {
      _error = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _authToken = null;
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
    } catch (e) {
      _error = 'Error logging out';
    } finally {
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _error = 'Error sending reset email';
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        // Store additional user data if needed
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(_user!.uid).update(updates);

      // Update Firebase Auth profile
      if (firstName != null || lastName != null) {
        await _user!.updateDisplayName('$firstName $lastName');
      }

    } catch (e) {
      _error = 'Error updating profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          // Navigate to OTP screen
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      _error = 'Error verifying phone number';
      notifyListeners();
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_user == null) return null;
    
    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
    }
    return null;
  }
}