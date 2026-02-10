import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethio_shop/providers/auth_provider.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, UserCredential, User, FirebaseFirestore])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late AuthProvider authProvider;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    
    // Setup SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    
    authProvider = AuthProvider.test(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
    );
  });

  group('AuthProvider Tests', () {
    test('Initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.user, null);
    });

    test('Login with email success', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      await authProvider.loginWithEmail('test@example.com', 'password123');

      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user, mockUser);
      expect(authProvider.isLoading, false);
    });

    test('Login with invalid credentials', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'wrong@example.com',
        password: 'wrong',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act
      await authProvider.loginWithEmail('wrong@example.com', 'wrong');

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.error, isNotNull);
      expect(authProvider.isLoading, false);
    });

    test('Register new user success', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('new_user_uid');
      
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('new_user_uid')).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => Future.value());

      // Act
      await authProvider.register(
        email: 'new@example.com',
        phone: '+251911111111',
        password: 'password123',
        firstName: 'Test',
        lastName: 'User',
        userType: 'buyer',
      );

      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.isLoading, false);
    });

    test('Logout clears user data', () async {
      // Arrange - First login
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      await authProvider.loginWithEmail('test@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      // Arrange - Logout
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });

    test('Reset password sends email', () async {
      // Arrange
      when(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'))
          .thenAnswer((_) async => Future.value());

      // Act
      await authProvider.resetPassword('test@example.com');

      // Assert - Should complete without error
      expect(authProvider.error, isNull);
    });

    test('Phone number validation', () async {
      // Test valid Ethiopian numbers
      expect(authProvider.validatePhone('0911111111'), true);
      expect(authProvider.validatePhone('+251911111111'), true);
      expect(authProvider.validatePhone('911111111'), true);

      // Test invalid numbers
      expect(authProvider.validatePhone('123'), false);
      expect(authProvider.validatePhone('091111111'), false); // Too short
    });

    test('Update profile success', () async {
      // First login
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      await authProvider.loginWithEmail('test@example.com', 'password123');

      // Setup Firestore mock for update
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('test_uid')).thenReturn(mockDocument);
      when(mockDocument.update(any)).thenAnswer((_) async => Future.value());
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async => Future.value());

      // Act
      await authProvider.updateProfile(
        firstName: 'Updated',
        lastName: 'Name',
        phone: '+251922222222',
      );

      // Assert
      expect(authProvider.isLoading, false);
      expect(authProvider.error, isNull);
    });
  });
}

// Extended AuthProvider for testing
extension TestAuthProvider on AuthProvider {
  factory AuthProvider.test({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {
    final provider = AuthProvider();
    if (firebaseAuth != null) {
      // Use reflection or make _firebaseAuth public for testing
    }
    return provider;
  }
}