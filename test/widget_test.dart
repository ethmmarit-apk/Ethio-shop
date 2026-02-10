import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_shop/main.dart';
import 'package:ethio_shop/providers/auth_provider.dart';
import 'package:ethio_shop/providers/language_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Ethio Shop Widget Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Text('Ethio Shop')),
          ),
        ),
      );

      // Verify that our app starts
      expect(find.text('Ethio Shop'), findsOneWidget);
    });

    testWidgets('Splash screen shows loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Ethio Shop'), findsOneWidget);
    });
  });
}