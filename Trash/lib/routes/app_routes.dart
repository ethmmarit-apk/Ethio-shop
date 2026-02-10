import 'package:flutter/material.dart';
import 'package:ethio_shop/screens/splash_screen.dart';
import 'package:ethio_shop/screens/auth/login_screen.dart';
import 'package:ethio_shop/screens/auth/register_screen.dart';
import 'package:ethio_shop/screens/home_screen.dart';
import 'package:ethio_shop/screens/product_detail_screen.dart';
import 'package:ethio_shop/screens/cart_screen.dart';
import 'package:ethio_shop/screens/checkout_screen.dart';
import 'package:ethio_shop/screens/profile_screen.dart';
import 'package:ethio_shop/screens/orders_screen.dart';
import 'package:ethio_shop/screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String settings = '/settings';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String categories = '/categories';
  static const String sell = '/sell';
  static const String forgotPassword = '/forgot-password';
  static const String verifyPhone = '/verify-phone';
  static const String orderSuccess = '/order-success';
  static const String orderTracking = '/order-tracking';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case productDetails:
        final product = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product ?? {}),
        );
      
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      // Add more routes as needed
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method to get route names
  static List<String> get allRoutes => [
    splash,
    login,
    register,
    home,
    productDetails,
    cart,
    checkout,
    profile,
    orders,
    settings,
    chat,
    search,
    categories,
    sell,
    forgotPassword,
    verifyPhone,
    orderSuccess,
    orderTracking,
  ];

  // Check if route exists
  static bool exists(String routeName) {
    return allRoutes.contains(routeName);
  }

  // Get route from index (for bottom navigation)
  static String getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return search;
      case 2:
        return chat;
      case 3:
        return profile;
      default:
        return home;
    }
  }

  // Get index from route (for bottom navigation)
  static int getIndexFromRoute(String routeName) {
    switch (routeName) {
      case home:
        return 0;
      case search:
        return 1;
      case chat:
        return 2;
      case profile:
        return 3;
      default:
        return 0;
    }
  }
}

// Route observer for analytics
class RouteObserver extends NavigatorObserver {
  final List<String> _routeHistory = [];

  List<String> get routeHistory => List.from(_routeHistory);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    if (routeName != null) {
      _routeHistory.add(routeName);
      print('📱 Route pushed: $routeName');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_routeHistory.isNotEmpty) {
      _routeHistory.removeLast();
    }
    print('📱 Route popped');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newRouteName = newRoute?.settings.name;
    final oldRouteName = oldRoute?.settings.name;
    print('📱 Route replaced: $oldRouteName -> $newRouteName');
  }

  String get currentRoute {
    if (_routeHistory.isEmpty) return AppRoutes.splash;
    return _routeHistory.last;
  }

  bool isOnRoute(String routeName) {
    return currentRoute == routeName;
  }

  void clearHistory() {
    _routeHistory.clear();
  }
}

// Route guard for authentication
class AuthGuard {
  static bool canAccess(String routeName, bool isAuthenticated) {
    // Routes that don't require authentication
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.verifyPhone,
    ];

    // If route is public, allow access
    if (publicRoutes.contains(routeName)) {
      return true;
    }

    // Protected routes require authentication
    return isAuthenticated;
  }

  static String getRedirectRoute(bool isAuthenticated) {
    return isAuthenticated ? AppRoutes.home : AppRoutes.login;
  }
}