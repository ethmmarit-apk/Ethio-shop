import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ethio_shop/providers/auth_provider.dart';
import 'package:ethio_shop/providers/language_provider.dart';
import 'package:ethio_shop/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize providers
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Wait for initializations
    await Future.wait([
      authProvider.initialize(),
      languageProvider.initialize(),
      Future.delayed(const Duration(seconds: 2)), // Minimum splash time
    ]);
    
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            
            // App name
            const Text(
              'Ethio Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            
            // Ethiopian name
            const Text(
              'ኢትዮ ሻፕ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
            const SizedBox(height: 5),
            
            // Tagline
            const Text(
              'Your Ethiopian Marketplace',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading indicator
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(8),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            
            // Loading text
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(
                  languageProvider.translate('loading') ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                );
              },
            ),
            
            // Version info
            const SizedBox(height: 50),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}