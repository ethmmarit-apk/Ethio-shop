import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethio_shop/providers/auth_provider.dart';
import 'package:ethio_shop/providers/language_provider.dart';
import 'package:ethio_shop/providers/cart_provider.dart';
import 'package:ethio_shop/providers/theme_provider.dart';

/// Test helpers for Ethio Shop app
class TestHelpers {
  /// Create a test app with providers
  static Widget createTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  /// Set up mock SharedPreferences
  static Future<void> setupMockSharedPrefs(
      Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
  }

  /// Pump and settle with delay
  static Future<void> pumpAndSettleWithDelay(
      WidgetTester tester, Duration delay) async {
    await tester.pumpAndSettle();
    await tester.pump(delay);
  }

  /// Find text ignoring case
  static Finder findTextIgnoreCase(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.data ?? '').toLowerCase().contains(text.toLowerCase()),
    );
  }

  /// Tap and wait
  static Future<void> tapAndWait(
      WidgetTester tester, Finder finder, Duration duration) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(duration);
  }

  /// Enter text in field
  static Future<void> enterTextInField(
      WidgetTester tester, Key key, String text) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
    await tester.enterText(find.byKey(key), text);
    await tester.pump();
  }

  /// Scroll to widget
  static Future<void> scrollToWidget(
      WidgetTester tester, Finder finder) async {
    await tester.dragUntilVisible(
      finder,
      find.byType(Scrollable),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
  }

  /// Create mock product data
  static Map<String, dynamic> createMockProduct({
    String id = '1',
    String title = 'Test Product',
    String description = 'Test Description',
    double price = 100.0,
    String image = 'https://picsum.photos/200',
    String location = 'Addis Ababa',
    double rating = 4.5,
    String seller = 'Test Seller',
    String status = 'new',
    String category = 'Electronics',
  }) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'location': location,
      'rating': rating,
      'seller': seller,
      'status': status,
      'category': category,
    };
  }

  /// Create mock user data
  static Map<String, dynamic> createMockUser({
    String uid = 'test_uid',
    String email = 'test@example.com',
    String phone = '+251911111111',
    String firstName = 'Test',
    String lastName = 'User',
    String userType = 'buyer',
  }) {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'createdAt': DateTime.now().toIso8601String(),
      'rating': 0.0,
      'totalRatings': 0,
    };
  }

  /// Verify snackbar appears
  static Future<void> verifySnackbar(
      WidgetTester tester, String message) async {
    expect(find.text(message), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Take screenshot for golden tests
  static Future<void> takeScreenshot(
      WidgetTester tester, String fileName) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('screenshots/$fileName.png'),
    );
  }

  /// Create mock cart item
  static Map<String, dynamic> createMockCartItem({
    String productId = '1',
    String productName = 'Test Product',
    double price = 100.0,
    int quantity = 1,
  }) {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': price * quantity,
    };
  }

  /// Wait for animations
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Clear all text fields
  static Future<void> clearAllTextFields(WidgetTester tester) async {
    final textFields = find.byType(TextField);
    for (final finder in textFields.evaluate()) {
      final textField = tester.widget<TextField>(finder);
      if (textField.controller != null) {
        textField.controller?.clear();
      }
    }
    await tester.pump();
  }

  /// Get widget by type
  static T getWidgetByType<T>(WidgetTester tester) {
    return tester.widget(find.byType(T).first) as T;
  }

  /// Find ancestor widget
  static T? findAncestorWidgetOfExactType<T extends Widget>(
      WidgetTester tester, Finder finder) {
    final element = finder.evaluate().first;
    return element.findAncestorWidgetOfExactType<T>();
  }

  /// Check if widget is visible
  static bool isWidgetVisible(Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  /// Get text from widget
  static String getTextFromWidget(Finder finder) {
    final widget = finder.evaluate().first.widget;
    if (widget is Text) {
      return widget.data ?? '';
    }
    return '';
  }
}