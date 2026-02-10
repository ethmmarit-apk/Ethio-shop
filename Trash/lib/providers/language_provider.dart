import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('am', 'ET');
  Map<String, Map<String, String>> _translations = {};
  bool _isLoading = false;

  Locale get locale => _locale;
  String get currentLanguage => _locale.languageCode;
  bool get isLoading => _isLoading;

  static final Map<String, Map<String, String>> _defaultTranslations = {
    'en': {
      'appTitle': 'Ethio Shop',
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'searchHint': 'Search products...',
      'categories': 'Categories',
      'featuredProducts': 'Featured Products',
      'seeAll': 'See All',
      'deliveryTo': 'Delivery to',
      'change': 'Change',
      'specialOffer': 'Special Offer',
      'discountText': 'Get up to 50% off',
      'shopNow': 'Shop Now',
      'recentlyViewed': 'Recently Viewed',
      'addToCart': 'Add to Cart',
      'buyNow': 'Buy Now',
      'price': 'Price',
      'quantity': 'Quantity',
      'total': 'Total',
      'proceedToCheckout': 'Proceed to Checkout',
      'yourCart': 'Your Cart',
      'emptyCart': 'Your cart is empty',
      'startShopping': 'Start Shopping',
      'checkout': 'Checkout',
      'deliveryAddress': 'Delivery Address',
      'paymentMethod': 'Payment Method',
      'orderSummary': 'Order Summary',
      'placeOrder': 'Place Order',
      'orderPlaced': 'Order Placed',
      'trackOrder': 'Track Order',
      'continueShopping': 'Continue Shopping',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'darkMode': 'Dark Mode',
      'notifications': 'Notifications',
      'help': 'Help',
      'about': 'About',
      'contactUs': 'Contact Us',
      'terms': 'Terms & Conditions',
      'privacy': 'Privacy Policy',
      'version': 'Version',
      'logoutConfirm': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Info',
      'tryAgain': 'Try Again',
      'noInternet': 'No Internet Connection',
      'serverError': 'Server Error',
      'somethingWrong': 'Something went wrong',
      'retry': 'Retry',
      'goBack': 'Go Back',
      'next': 'Next',
      'previous': 'Previous',
      'done': 'Done',
      'skip': 'Skip',
      'continue': 'Continue',
      'finish': 'Finish',
    },
    'am': {
      'appTitle': 'ኢትዮ ሻፕ',
      'welcome': 'እንኳን ደህና መጡ',
      'loading': 'በመጫን ላይ...',
      'searchHint': 'ምርቶችን ፈልግ...',
      'categories': 'ምድቦች',
      'featuredProducts': 'የተለዩ ምርቶች',
      'seeAll': 'ሁሉንም ይመልከቱ',
      'deliveryTo': 'የማድረሻ አድራሻ',
      'change': 'ቀይር',
      'specialOffer': 'ልዩ ቅናሽ',
      'discountText': 'እስከ 50% ቅናሽ ያግኙ',
      'shopNow': 'አሁን ይግዙ',
      'recentlyViewed': 'ያለፉት',
      'addToCart': 'ወደ ጋሪ ጨምር',
      'buyNow': 'አሁን ይግዙ',
      'price': 'ዋጋ',
      'quantity': 'ብዛት',
      'total': 'ጠቅላላ',
      'proceedToCheckout': 'ወደ ክፍያ ይሂዱ',
      'yourCart': 'ጋሪዎ',
      'emptyCart': 'ጋሪዎ ባዶ ነው',
      'startShopping': 'ግዢ ጀምር',
      'checkout': 'ክፍያ',
      'deliveryAddress': 'የማድረሻ አድራሻ',
      'paymentMethod': 'የክፍያ መንገድ',
      'orderSummary': 'የትዕዛዝ ማጠቃለያ',
      'placeOrder': 'ትዕዛዝ አስገባ',
      'orderPlaced': 'ትዕዛዝ ተጠናቋል',
      'trackOrder': 'ትዕዛዝ ይከታተሉ',
      'continueShopping': 'ግዢውን ቀጥል',
      'login': 'ግባ',
      'register': 'ተመዝገብ',
      'logout': 'ውጣ',
      'profile': 'መለያ',
      'settings': 'ቅንብሮች',
      'language': 'ቋንቋ',
      'darkMode': 'ጨለማ ሞድ',
      'notifications': 'ማሳወቂያዎች',
      'help': 'እርዳታ',
      'about': 'ስለ እኛ',
      'contactUs': 'ያግኙን',
      'terms': 'ውሎች እና ሁኔታዎች',
      'privacy': 'የግላዊነት ፖሊሲ',
      'version': 'እትም',
      'logoutConfirm': 'እርግጠኛ ነዎት መውጣት ይፈልጋሉ?',
      'yes': 'አዎ',
      'no': 'አይ',
      'cancel': 'ሰርዝ',
      'save': 'አስቀምጥ',
      'edit': 'አርትዕ',
      'delete': 'ሰርዝ',
      'confirm': 'አረጋግጥ',
      'success': 'ተሳክቷል',
      'error': 'ስህተት',
      'warning': 'ማስጠንቀቂያ',
      'info': 'መረጃ',
      'tryAgain': 'እንደገና ይሞክሩ',
      'noInternet': 'የበይነመረብ ግንኙነት የለም',
      'serverError': 'የሰርቨር ስህተት',
      'somethingWrong': 'ስህተት ተከስቷል',
      'retry': 'እንደገና ይሞክሩ',
      'goBack': 'ተመለስ',
      'next': 'ቀጣይ',
      'previous': 'ቀዳሚ',
      'done': 'ተጠናቅቋል',
      'skip': 'ዝለል',
      'continue': 'ቀጥል',
      'finish': 'ጨርስ',
    },
    'om': {
      'appTitle': 'Dukaanii Itoophiyaa',
      'welcome': 'Baga Nagaan Dhuftan',
      'loading': 'Hirmaachuu...',
      // Add more Oromo translations
    },
    'ti': {
      'appTitle': 'ዕድገት ዕዳጋ',
      'welcome': 'እንቋዕ ብድሓን መጻእኩም',
      'loading': 'ተጻዒቑ...',
      // Add more Tigrinya translations
    },
  };

  LanguageProvider() {
    _loadSavedLanguage();
  }

  static Future<void> initialize() async {
    // Static initialization if needed
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language') ?? 'am';
      final countryCode = prefs.getString('country') ?? 'ET';
      
      _locale = Locale(languageCode, countryCode);
      _loadTranslations();
    } catch (e) {
      _locale = const Locale('am', 'ET');
      _loadTranslations();
    }
  }

  Future<void> setLanguage(Locale newLocale) async {
    _isLoading = true;
    notifyListeners();

    try {
      _locale = newLocale;
      _loadTranslations();
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', newLocale.languageCode);
      await prefs.setString('country', newLocale.countryCode ?? 'ET');
    } catch (e) {
      // Revert on error
      _locale = const Locale('am', 'ET');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadTranslations() {
    // Start with default translations
    _translations = Map.from(_defaultTranslations);
    
    // In production, you would load from assets/API
    // For now, we use the default translations
  }

  String? translate(String key) {
    return _translations[_locale.languageCode]?[key] ??
           _translations['en']?[key] ??
           key;
  }

  List<Map<String, dynamic>> get availableLanguages => [
    {
      'code': 'am',
      'name': 'አማርኛ',
      'locale': const Locale('am', 'ET'),
      'flag': '🇪🇹',
    },
    {
      'code': 'en',
      'name': 'English',
      'locale': const Locale('en', 'US'),
      'flag': '🇺🇸',
    },
    {
      'code': 'om',
      'name': 'Oromiffa',
      'locale': const Locale('om', 'ET'),
      'flag': '🇪🇹',
    },
    {
      'code': 'ti',
      'name': 'ትግርኛ',
      'locale': const Locale('ti', 'ET'),
      'flag': '🇪🇹',
    },
  ];

  String get currentLanguageName {
    final lang = availableLanguages.firstWhere(
      (lang) => lang['code'] == _locale.languageCode,
      orElse: () => availableLanguages[0],
    );
    return lang['name'] as String;
  }

  String get currentFlag {
    final lang = availableLanguages.firstWhere(
      (lang) => lang['code'] == _locale.languageCode,
      orElse: () => availableLanguages[0],
    );
    return lang['flag'] as String;
  }

  Future<void> resetToDefault() async {
    await setLanguage(const Locale('am', 'ET'));
  }
}