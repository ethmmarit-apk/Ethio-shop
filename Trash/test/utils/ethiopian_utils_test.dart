import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_shop/utils/ethiopian_utils.dart';

void main() {
  group('EthiopianUtils Tests', () {
    test('Phone number formatting', () {
      expect(EthiopianUtils.formatPhone('0911111111'), '+251911111111');
      expect(EthiopianUtils.formatPhone('+251911111111'), '+251911111111');
      expect(EthiopianUtils.formatPhone('911111111'), '+251911111111');
      expect(EthiopianUtils.formatPhone('251911111111'), '+251911111111');
      expect(EthiopianUtils.formatPhone('123'), null);
    });

    test('Phone number validation', () {
      expect(EthiopianUtils.validatePhone('0911111111'), true);
      expect(EthiopianUtils.validatePhone('+251911111111'), true);
      expect(EthiopianUtils.validatePhone('0912111111'), true); // 12...
      expect(EthiopianUtils.validatePhone('091111111'), false); // Too short
      expect(EthiopianUtils.validatePhone('0811111111'), false); // Invalid prefix
      expect(EthiopianUtils.validatePhone(''), false);
    });

    test('ETB currency formatting', () {
      expect(EthiopianUtils.formatETB(1000), 'ETB 1,000.00');
      expect(EthiopianUtils.formatETB(1500.50), 'ETB 1,500.50');
      expect(EthiopianUtils.formatETB(0), 'ETB 0.00');
      expect(EthiopianUtils.formatETB(999999), 'ETB 999,999.00');
    });

    test('ETB compact formatting', () {
      expect(EthiopianUtils.formatETBCompact(1000), '1.0K ETB');
      expect(EthiopianUtils.formatETBCompact(1500000), '1.5M ETB');
      expect(EthiopianUtils.formatETBCompact(500), 'ETB 500.00');
      expect(EthiopianUtils.formatETBCompact(0), 'ETB 0.00');
    });

    test('Ethiopian regions list', () {
      final regions = EthiopianUtils.getRegions();
      expect(regions, isNotEmpty);
      expect(regions.length, greaterThan(5));
      
      // Check specific regions
      final addisAbaba = regions.firstWhere(
        (region) => region['id'] == 'addis_ababa'
      );
      expect(addisAbaba['name'], 'Addis Ababa');
      expect(addisAbaba['name_am'], 'አዲስ አበባ');
    });

    test('Cities by region', () {
      final cities = EthiopianUtils.getCities('addis_ababa');
      expect(cities, isNotEmpty);
      expect(cities, contains('Addis Ababa'));
      expect(cities, contains('ቦሌ'));
      
      final oromiaCities = EthiopianUtils.getCities('oromia');
      expect(oromiaCities, contains('Adama'));
      expect(oromiaCities, contains('Jimma'));
    });

    test('Ethiopian date conversion', () {
      // Test Gregorian to Ethiopian conversion
      final gregorianDate = DateTime(2024, 9, 11); // Ethiopian New Year
      final ethiopianDate = EthiopianUtils.toEthiopianDate(gregorianDate);
      
      expect(ethiopianDate['year'], 2017); // Ethiopian year 2017
      expect(ethiopianDate['month'], 1); // Meskerem
      expect(ethiopianDate['day'], 1); // New Year's Day
      expect(ethiopianDate['monthNameAm'], 'መስከረም');
    });

    test('Month names in Amharic', () {
      expect(EthiopianUtils.getMonthNameAmharic(1), 'መስከረም');
      expect(EthiopianUtils.getMonthNameAmharic(2), 'ጥቅምት');
      expect(EthiopianUtils.getMonthNameAmharic(13), 'ጳጉሜ');
      expect(EthiopianUtils.getMonthNameAmharic(0), '');
      expect(EthiopianUtils.getMonthNameAmharic(14), '');
    });

    test('Ethiopian holidays', () {
      final holidays2024 = EthiopianUtils.getHolidays(2024);
      expect(holidays2024, isNotEmpty);
      
      final newYear = holidays2024.firstWhere(
        (holiday) => holiday['name'] == 'Ethiopian New Year'
      );
      expect(newYear['date'], '2024-09-11');
      expect(newYear['name_am'], 'አዲስ ዓመት');
      expect(newYear['type'], 'national');
    });

    test('Holiday check', () {
      final newYearDate = DateTime(2024, 9, 11);
      final regularDate = DateTime(2024, 6, 15);
      
      expect(EthiopianUtils.isHoliday(newYearDate), true);
      expect(EthiopianUtils.isHoliday(regularDate), false);
    });

    test('Address formatting', () {
      final address = EthiopianUtils.formatAddress(
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        subcity: 'Bole',
        woreda: '03',
        kebele: '05',
        houseNumber: '123',
      );
      
      expect(address, 'Addis Ababa, Bole, Woreda 03, Kebele 05, House 123');
      
      final amharicAddress = EthiopianUtils.formatAddressAmharic(
        region: 'Addis Ababa',
        city: 'Addis Ababa',
        subcity: 'Bole',
        woreda: '03',
        kebele: '05',
        houseNumber: '123',
      );
      
      expect(amharicAddress, 'Addis Ababa, ክፍለ ከተማ Bole, ወረዳ 03, ቀበሌ 05, ቤት 123');
    });

    test('Time formatting', () {
      final morningTime = DateTime(2024, 1, 1, 9, 30);
      final eveningTime = DateTime(2024, 1, 1, 21, 45);
      
      expect(EthiopianUtils.formatTime(morningTime, twelveHour: true), '9:30 AM');
      expect(EthiopianUtils.formatTime(eveningTime, twelveHour: true), '9:45 PM');
      expect(EthiopianUtils.formatTime(morningTime, twelveHour: false), '9:30');
    });

    test('Amharic number formatting', () {
      expect(EthiopianUtils.formatNumberAmharic(123), '١٢٣');
      expect(EthiopianUtils.formatNumberAmharic(0), '٠');
      expect(EthiopianUtils.formatNumberAmharic(999), '٩٩٩');
    });

    test('Name validation', () {
      expect(EthiopianUtils.isValidEthiopianName('ሙሉ'), true);
      expect(EthiopianUtils.isValidEthiopianName('John'), true);
      expect(EthiopianUtils.isValidEthiopianName('A'), false);
      expect(EthiopianUtils.isValidEthiopianName(''), false);
      expect(EthiopianUtils.isValidEthiopianName('Very Long Name That Exceeds Maximum Length'), true);
    });

    test('Kebele and Woreda validation', () {
      expect(EthiopianUtils.isValidKebele('05'), true);
      expect(EthiopianUtils.isValidKebele('123'), true);
      expect(EthiopianUtils.isValidKebele('abc'), false);
      expect(EthiopianUtils.isValidKebele(''), false);
      
      expect(EthiopianUtils.isValidWoreda('03'), true);
      expect(EthiopianUtils.isValidWoreda('999'), true);
      expect(EthiopianUtils.isValidWoreda('1000'), false);
      expect(EthiopianUtils.isValidWoreda('abc'), false);
    });

    test('Region name retrieval', () {
      expect(EthiopianUtils.getRegionName('addis_ababa'), 'Addis Ababa');
      expect(EthiopianUtils.getRegionName('addis_ababa', language: 'am'), 'አዲስ አበባ');
      expect(EthiopianUtils.getRegionName('oromia'), 'Oromia');
      expect(EthiopianUtils.getRegionName('nonexistent'), 'Addis Ababa'); // Default
    });
  });
}