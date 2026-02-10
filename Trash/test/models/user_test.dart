import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_shop/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User creates correctly from JSON', () {
      final json = {
        'id': 'user1',
        'email': 'test@example.com',
        'phone': '+251911111111',
        'firstName': 'ሙሉ',
        'lastName': 'ገብረኢየሱስ',
        'userType': 'buyer',
        'region': 'Addis Ababa',
        'city': 'Addis Ababa',
        'subcity': 'Bole',
        'woreda': '03',
        'kebele': '05',
        'profileImageUrl': 'https://example.com/photo.jpg',
        'rating': 4.8,
        'totalRatings': 25,
        'verificationStatus': 'verified',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user1');
      expect(user.email, 'test@example.com');
      expect(user.phone, '+251911111111');
      expect(user.firstName, 'ሙሉ');
      expect(user.userType, UserType.buyer);
      expect(user.region, 'Addis Ababa');
      expect(user.verificationStatus, VerificationStatus.verified);
      expect(user.rating, 4.8);
      expect(user.totalRatings, 25);
    });

    test('User converts to JSON correctly', () {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.seller,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        subcity: 'Bole',
        woreda: '03',
        kebele: '05',
        profileImageUrl: 'https://example.com/photo.jpg',
        rating: 4.5,
        totalRatings: 10,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], 'user1');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '+251911111111');
      expect(json['userType'], 'seller');
      expect(json['verificationStatus'], 'pending');
    });

    test('User full name getter', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'ሙሉ',
        lastName: 'ገብረኢየሱስ',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.fullName, 'ሙሉ ገብረኢየሱስ');
    });

    test('User address getter', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        subcity: 'Bole',
        woreda: '03',
        kebele: '05',
        houseNumber: '123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.address,
          'Addis Ababa, Bole, Woreda 03, Kebele 05, House 123');
    });

    test('User isVerified getter', () {
      final verifiedUser = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pendingUser = User(
        id: '2',
        email: 'test2@example.com',
        phone: '+251922222222',
        firstName: 'Test2',
        lastName: 'User2',
        userType: UserType.seller,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(verifiedUser.isVerified, true);
      expect(pendingUser.isVerified, false);
    });

    test('User copyWith method', () {
      final originalUser = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Original',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedUser = originalUser.copyWith(
        firstName: 'Updated',
        lastName: 'Name',
        phone: '+251922222222',
      );

      expect(updatedUser.id, '1');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.firstName, 'Updated');
      expect(updatedUser.lastName, 'Name');
      expect(updatedUser.phone, '+251922222222');
      expect(updatedUser.region, 'Addis Ababa');
    });

    test('User equality', () {
      final user1 = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user2 = User(
        id: '1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: user1.createdAt,
        updatedAt: user1.updatedAt,
      );

      final user3 = User(
        id: '2',
        email: 'test2@example.com',
        phone: '+251922222222',
        firstName: 'Test2',
        lastName: 'User2',
        userType: UserType.seller,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user1, user2);
      expect(user1 == user3, false);
    });

    test('User toString method', () {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        phone: '+251911111111',
        firstName: 'Test',
        lastName: 'User',
        userType: UserType.buyer,
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      expect(user.toString(), contains('user1'));
      expect(user.toString(), contains('test@example.com'));
      expect(user.toString(), contains('Test User'));
    });
  });
}