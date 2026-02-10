import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ethio_shop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end tests', () {
    testWidgets('Complete user flow: Login → Browse → Add to Cart → Checkout',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));

      // Should be on login screen
      expect(find.text('Welcome Back'), findsOneWidget);

      // Enter login credentials
      await tester.enterText(
          find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on home screen
      expect(find.text('Ethio Shop'), findsOneWidget);
      expect(find.text('Featured Products'), findsOneWidget);

      // Tap on a product
      await tester.tap(find.text('iPhone 14 Pro').first);
      await tester.pumpAndSettle();

      // Should be on product details screen
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);

      // Add to cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();

      // Go to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Should be on cart screen
      expect(find.text('Your Cart'), findsOneWidget);
      expect(find.text('iPhone 14 Pro'), findsOneWidget);

      // Proceed to checkout
      await tester.tap(find.text('Proceed to Checkout'));
      await tester.pumpAndSettle();

      // Should be on checkout screen
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);

      // Fill delivery address
      await tester.enterText(
          find.byKey(const Key('city_field')), 'Addis Ababa');
      await tester.enterText(
          find.byKey(const Key('subcity_field')), 'Bole');
      await tester.enterText(find.byKey(const Key('woreda_field')), '03');
      await tester.enterText(find.byKey(const Key('kebele_field')), '05');
      await tester.pump();

      // Select payment method
      await tester.tap(find.text('Cash on Delivery').first);
      await tester.pump();

      // Place order
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show order success
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
    });

    testWidgets('Product search flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to home
      await tester.pumpAndSettle();

      // Tap search bar
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
          find.byType(TextField), 'iPhone');
      await tester.pump();

      // Should show search results
      expect(find.text('iPhone'), findsAtLeast(1));

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
    });

    testWidgets('Language switching', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Go to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Tap language option
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Select Amharic
      await tester.tap(find.text('አማርኛ'));
      await tester.pumpAndSettle();

      // Verify UI switched to Amharic
      expect(find.text('ኢትዮ ሻፕ'), findsOneWidget);

      // Switch back to English
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
    });

    testWidgets('Dark mode toggle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to profile → settings
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Toggle dark mode
      final darkModeSwitch = find.byKey(const Key('dark_mode_switch'));
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // App should be in dark mode
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.grey[900]);

      // Toggle back to light mode
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();
    });
  });
}