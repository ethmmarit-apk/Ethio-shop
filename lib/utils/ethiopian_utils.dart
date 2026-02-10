import 'package:intl/intl.dart';

class EthiopianUtils {
  static final NumberFormat _etbFormatter = NumberFormat.currency(
    locale: 'am_ET',
    symbol: 'ETB',
    decimalDigits: 2,
  );

  static final NumberFormat _etbNoSymbol = NumberFormat.currency(
    locale: 'am_ET',
    symbol: '',
    decimalDigits: 2,
  );

  // Ethiopian regions and cities
  static final List<Map<String, dynamic>> _ethiopianRegions = [
    {
      'id': 'addis_ababa',
      'name': 'Addis Ababa',
      'name_am': 'አዲስ አበባ',
      'cities': [
        'Addis Ababa',
        'ማህተም',
        'ቦሌ',
        'አያት',
        'ኮልፌ ከራንዮ',
        'ንፋስ ስልክ ላፍቶ',
        'አካኪ ቃሊቲ',
        'የካ',
      ],
    },
    {
      'id': 'oromia',
      'name': 'Oromia',
      'name_am': 'ኦሮሚያ',
      'cities': [
        'Adama',
        'Ambo',
        'Bishoftu',
        'Jimma',
        'Shashamane',
        'Woliso',
        'Nekemte',
        'Bale Robe',
      ],
    },
    {
      'id': 'amhara',
      'name': 'Amhara',
      'name_am': 'አማራ',
      'cities': [
        'Bahir Dar',
        'Gondar',
        'Dessie',
        'Debre Markos',
        'Debre Birhan',
        'Kombolcha',
        'Woldia',
      ],
    },
    {
      'id': 'tigray',
      'name': 'Tigray',
      'name_am': 'ትግራይ',
      'cities': [
        'Mekele',
        'Adwa',
        'Axum',
        'Shire',
        'Humera',
        'Adigrat',
      ],
    },
    {
      'id': 'snnp',
      'name': 'Southern Nations',
      'name_am': 'ደቡብ ብሔሮች',
      'cities': [
        'Hawassa',
        'Arba Minch',
        'Dilla',
        'Sodo',
        'Wolaita Sodo',
        'Hosaena',
      ],
    },
    {
      'id': 'somali',
      'name': 'Somali',
      'name_am': 'ሶማሌ',
      'cities': [
        'Jijiga',
        'Dire Dawa',
        'Kebri Dehar',
        'Gode',
        'Dega Habur',
      ],
    },
  ];

  // Ethiopian holidays
  static final List<Map<String, dynamic>> _ethiopianHolidays = [
    {
      'date': '01-07',
      'name': 'Christmas',
      'name_am': 'ገና',
      'type': 'religious',
    },
    {
      'date': '01-19',
      'name': 'Timkat',
      'name_am': 'ጥምቀት',
      'type': 'religious',
    },
    {
      'date': '03-02',
      'name': 'Adwa Victory Day',
      'name_am': 'አድዋ',
      'type': 'national',
    },
    {
      'date': '04-20',
      'name': 'Easter',
      'name_am': 'ፋሲካ',
      'type': 'religious',
    },
    {
      'date': '05-01',
      'name': 'Labour Day',
      'name_am': 'የሰራተኞች ቀን',
      'type': 'international',
    },
    {
      'date': '05-28',
      'name': 'Downfall of Derg',
      'name_am': 'ደርግ የወደቀበት ቀን',
      'type': 'national',
    },
    {
      'date': '09-11',
      'name': 'Ethiopian New Year',
      'name_am': 'አዲስ ዓመት',
      'type': 'national',
    },
    {
      'date': '09-27',
      'name': 'Meskel',
      'name_am': 'መስቀል',
      'type': 'religious',
    },
  ];

  // Ethiopian month names
  static final List<String> _ethiopianMonthsAmharic = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሳስ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዚያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜ',
  ];

  static final List<String> _ethiopianMonthsEnglish = [
    'Meskerem',
    'Tikimit',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  static Future<void> initialize() async {
    // Initialize any required resources
    await Future.delayed(Duration.zero);
  }

  // Phone number formatting and validation
  static String? formatPhone(String phone) {
    if (phone.isEmpty) return null;

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format: +251XXXXXXXXX
    if (digits.startsWith('251') && digits.length == 12) {
      return '+$digits';
    }

    // Format: 09XXXXXXXX
    if (digits.startsWith('0') && digits.length == 10) {
      return '+251${digits.substring(1)}';
    }

    // Format: 9XXXXXXXX (9 digits)
    if (digits.length == 9) {
      return '+251$digits';
    }

    // Format: 251XXXXXXXXX (without +)
    if (digits.length == 12) {
      return '+$digits';
    }

    return null;
  }

  static bool validatePhone(String phone) {
    final formatted = formatPhone(phone);
    if (formatted == null) return false;

    // Ethiopian mobile numbers: +2519XXXXXXXX or +2517XXXXXXXX
    final regex = RegExp(r'^\+251[79]\d{8}$');
    return regex.hasMatch(formatted);
  }

  static String? extractPhoneDigits(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ETB currency formatting
  static String formatETB(double amount, {bool withSymbol = true}) {
    if (withSymbol) {
      return _etbFormatter.format(amount);
    } else {
      return _etbNoSymbol.format(amount);
    }
  }

  static String formatETBCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ETB';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ETB';
    } else {
      return formatETB(amount);
    }
  }

  // Ethiopian regions and cities
  static List<Map<String, dynamic>> getRegions() {
    return List.from(_ethiopianRegions);
  }

  static List<String> getCities(String regionId) {
    final region = _ethiopianRegions.firstWhere(
      (region) => region['id'] == regionId,
      orElse: () => _ethiopianRegions[0],
    );
    return List<String>.from(region['cities'] as List);
  }

  static String getRegionName(String regionId, {String language = 'en'}) {
    final region = _ethiopianRegions.firstWhere(
      (region) => region['id'] == regionId,
      orElse: () => _ethiopianRegions[0],
    );
    return language == 'am' 
        ? region['name_am'] as String 
        : region['name'] as String;
  }

  // Ethiopian date utilities
  static Map<String, dynamic> toEthiopianDate(DateTime gregorianDate) {
    // Simple conversion (approximate)
    final year = gregorianDate.year;
    final month = gregorianDate.month;
    final day = gregorianDate.day;

    // Ethiopian year starts on September 11
    final ethiopianYear = month >= 9 ? year - 7 : year - 8;
    final ethiopianMonth = month >= 9 ? month - 8 : month + 4;
    final ethiopianDay = day;

    return {
      'year': ethiopianYear,
      'month': ethiopianMonth,
      'day': ethiopianDay,
      'monthNameAm': _ethiopianMonthsAmharic[ethiopianMonth - 1],
      'monthNameEn': _ethiopianMonthsEnglish[ethiopianMonth - 1],
      'formatted': '$ethiopianDay/${_ethiopianMonthsAmharic[ethiopianMonth - 1]}/$ethiopianYear',
      'formattedEn': '$ethiopianDay ${_ethiopianMonthsEnglish[ethiopianMonth - 1]} $ethiopianYear',
    };
  }

  static String getMonthNameAmharic(int month) {
    if (month < 1 || month > 13) return '';
    return _ethiopianMonthsAmharic[month - 1];
  }

  static String getMonthNameEnglish(int month) {
    if (month < 1 || month > 13) return '';
    return _ethiopianMonthsEnglish[month - 1];
  }

  // Ethiopian holidays
  static List<Map<String, dynamic>> getHolidays(int year) {
    return _ethiopianHolidays.map((holiday) {
      return {
        ...holiday,
        'date': '$year-${holiday['date']}',
        'isToday': _isToday('$year-${holiday['date']}'),
      };
    }).toList();
  }

  static bool isHoliday(DateTime date) {
    final monthDay = '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    
    return _ethiopianHolidays.any((holiday) => holiday['date'] == monthDay);
  }

  static bool _isToday(String dateString) {
    final today = DateTime.now();
    final date = DateTime.parse(dateString);
    return today.year == date.year &&
        today.month == date.month &&
        today.day == date.day;
  }

  // Address formatting
  static String formatAddress({
    required String region,
    required String city,
    String? subcity,
    String? woreda,
    String? kebele,
    String? houseNumber,
  }) {
    final parts = <String>[];
    
    if (city.isNotEmpty) parts.add(city);
    if (subcity != null && subcity.isNotEmpty) parts.add(subcity);
    if (woreda != null && woreda.isNotEmpty) parts.add('Woreda $woreda');
    if (kebele != null && kebele.isNotEmpty) parts.add('Kebele $kebele');
    if (houseNumber != null && houseNumber.isNotEmpty) parts.add('House $houseNumber');
    
    return parts.join(', ');
  }

  static String formatAddressAmharic({
    required String region,
    required String city,
    String? subcity,
    String? woreda,
    String? kebele,
    String? houseNumber,
  }) {
    final parts = <String>[];
    
    if (city.isNotEmpty) parts.add(city);
    if (subcity != null && subcity.isNotEmpty) parts.add('ክፍለ ከተማ $subcity');
    if (woreda != null && woreda.isNotEmpty) parts.add('ወረዳ $woreda');
    if (kebele != null && kebele.isNotEmpty) parts.add('ቀበሌ $kebele');
    if (houseNumber != null && houseNumber.isNotEmpty) parts.add('ቤት $houseNumber');
    
    return parts.join(', ');
  }

  // Ethiopian time formatting
  static String formatTime(DateTime time, {bool twelveHour = true}) {
    if (twelveHour) {
      final hour = time.hour % 12;
      final period = time.hour < 12 ? 'AM' : 'PM';
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  // Ethiopian number formatting (ቁጥር ቅርጽ)
  static String formatNumberAmharic(int number) {
    const amharicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final digits = number.toString().split('');
    return digits.map((digit) => amharicDigits[int.parse(digit)]).join('');
  }

  // Validation for Ethiopian specific fields
  static bool isValidEthiopianName(String name) {
    // Basic validation for Ethiopian names
    if (name.isEmpty) return false;
    if (name.length < 2) return false;
    return true;
  }

  static bool isValidKebele(String kebele) {
    if (kebele.isEmpty) return false;
    final regex = RegExp(r'^\d{1,3}$');
    return regex.hasMatch(kebele);
  }

  static bool isValidWoreda(String woreda) {
    if (woreda.isEmpty) return false;
    final regex = RegExp(r'^\d{1,3}$');
    return regex.hasMatch(woreda);
  }
}