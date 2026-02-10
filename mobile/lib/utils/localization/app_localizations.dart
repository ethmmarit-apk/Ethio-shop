import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  
  final Locale locale;
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate =
    _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Ethio Marketplace',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'phone': 'Phone',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'region': 'Region',
      'city': 'City',
      'subcity': 'Subcity',
      'woreda': 'Woreda',
      'kebele': 'Kebele',
      'search': 'Search products...',
      'categories': 'Categories',
      'featured': 'Featured',
      'recent': 'Recent',
      'price': 'Price',
      'etb': 'ETB',
      'negotiable': 'Negotiable',
      'addToCart': 'Add to Cart',
      'buyNow': 'Buy Now',
      'contactSeller': 'Contact Seller',
      'description': 'Description',
      'specifications': 'Specifications',
      'reviews': 'Reviews',
      'writeReview': 'Write Review',
      'myOrders': 'My Orders',
      'myProducts': 'My Products',
      'myProfile': 'My Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'help': 'Help',
      'about': 'About',
      'currency': 'Currency',
      'delivery': 'Delivery',
      'pickup': 'Pickup',
      'both': 'Both',
      'condition': 'Condition',
      'new': 'New',
      'used': 'Used',
      'location': 'Location',
      'filter': 'Filter',
      'sort': 'Sort',
      'clear': 'Clear',
      'apply': 'Apply',
      'chat': 'Chat',
      'typeMessage': 'Type a message...',
      'send': 'Send',
      'online': 'Online',
      'offline': 'Offline',
      'typing': 'typing...',
      'delivered': 'Delivered',
      'read': 'Read',
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'shipped': 'Shipped',
      'cancelled': 'Cancelled',
      'refunded': 'Refunded',
      'trackOrder': 'Track Order',
      'cancelOrder': 'Cancel Order',
      'rateSeller': 'Rate Seller',
      'uploadPhotos': 'Upload Photos',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'compressImage': 'Compress Image',
      'maxSize': 'Maximum size: 5MB',
      'processing': 'Processing...',
      'success': 'Success',
      'error': 'Error',
      'retry': 'Retry',
      'noInternet': 'No Internet Connection',
      'tryAgain': 'Try Again',
      'loading': 'Loading...',
      'noData': 'No Data Available',
    },
    'am': {
      'appTitle': 'ኢትዮ ማርኬትፕሌስ',
      'welcome': 'እንኳን ደህና መጡ',
      'login': 'ግባ',
      'register': 'ተመዝገብ',
      'email': 'ኢሜይል',
      'password': 'የይለፍ ቃል',
      'phone': 'ስልክ',
      'firstName': 'ስም',
      'lastName': 'የአባት ስም',
      'region': 'ክልል',
      'city': 'ከተማ',
      'subcity': 'ክፍለ ከተማ',
      'woreda': 'ወረዳ',
      'kebele': 'ቀበሌ',
      'search': 'ምርቶችን ፈልግ...',
      'categories': 'ምድቦች',
      'featured': 'የተለዩ',
      'recent': 'የቅርብ',
      'price': 'ዋጋ',
      'etb': 'ብር',
      'negotiable': 'ሊቀያይር የሚችል',
      'addToCart': 'ወደ ጋሪ ጨምር',
      'buyNow': 'አሁን ይግዙ',
      'contactSeller': 'ሻጭን ያነጋግሩ',
      'description': 'መግለጫ',
      'specifications': 'ዝርዝሮች',
      'reviews': 'ግምገማዎች',
      'writeReview': 'ግምገማ ጻፍ',
      'myOrders': 'ትዕዛዞቼ',
      'myProducts': 'ምርቶቼ',
      'myProfile': 'መለያዬ',
      'settings': 'ቅንብሮች',
      'logout': 'ውጣ',
      'language': 'ቋንቋ',
      'theme': 'ገጽታ',
      'notifications': 'ማሳወቂያዎች',
      'help': 'እርዳታ',
      'about': 'ስለ እኛ',
      'currency': 'ምንዛሪ',
      'delivery': 'ማድረስ',
      'pickup': 'ማንሳት',
      'both': 'ሁለቱም',
      'condition': 'ሁኔታ',
      'new': 'አዲስ',
      'used': 'የተጠቀመ',
      'location': 'አካባቢ',
      'filter': 'አጣራ',
      'sort': 'ደርድር',
      'clear': 'አጽዳ',
      'apply': 'ተግብር',
      'chat': 'ውይይት',
      'typeMessage': 'መልእክት ይጻፉ...',
      'send': 'ላክ',
      'online': 'በመስመር ላይ',
      'offline': 'ከመስመር ውጭ',
      'typing': 'በመጻፍ ላይ...',
      'delivered': 'ደረሰ',
      'read': 'ተነበበ',
      'pending': 'በመጠባበቅ ላይ',
      'confirmed': 'ተረጋግጧል',
      'shipped': 'ተልኳል',
      'cancelled': 'ተሰርዟል',
      'refunded': 'ተመልሷል',
      'trackOrder': 'ትዕዛዝ ይከታተሉ',
      'cancelOrder': 'ትዕዛዝ ሰርዝ',
      'rateSeller': 'ሻጭን ደረጃ ይስጡ',
      'uploadPhotos': 'ምስሎች ጫን',
      'camera': 'ካሜራ',
      'gallery': 'ጋሌሪ',
      'compressImage': 'ምስል አሳፍር',
      'maxSize': 'ከፍተኛ መጠን: 5 ሜጋ ባይት',
      'processing': 'በማቀናበር ላይ...',
      'success': 'ተሳክቷል',
      'error': 'ስህተት',
      'retry': 'እንደገና ይሞክሩ',
      'noInternet': 'የበይነመረብ ግንኙነት የለም',
      'tryAgain': 'እንደገና ይሞክሩ',
      'loading': 'በመጫን ላይ...',
      'noData': 'የሚገኝ ውሂብ የለም',
    },
    'om': {
      'appTitle': 'Ganda Gurgurta Itoophiyaa',
      'welcome': 'Baga Nagaan Dhuftan',
      // ... Oromo translations
    },
    'ti': {
      'appTitle': 'ዕድገት ዕዳጋ ኤርትራ',
      'welcome': 'እንቋዕ ብድሓን መጻእኩም',
      // ... Tigrinya translations
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'am', 'om', 'ti'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy translation
extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)?.translate(this) ?? this;
  }
}