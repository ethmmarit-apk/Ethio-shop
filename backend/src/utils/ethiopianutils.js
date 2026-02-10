// Ethiopian utilities for Ethio Marketplace

class EthiopianUtils {
  
  // Format Ethiopian phone number
  static formatPhone(phone) {
    if (!phone) return null;
    
    const digits = phone.replace(/\D/g, '');
    
    // Format: +251XXXXXXXXX
    if (digits.startsWith('251') && digits.length === 12) {
      return `+${digits}`;
    }
    
    // Format: 09XXXXXXXX
    if (digits.startsWith('0') && digits.length === 10) {
      return `+251${digits.substring(1)}`;
    }
    
    // Format: 9XXXXXXXX (9 digits)
    if (digits.length === 9) {
      return `+251${digits}`;
    }
    
    return null;
  }
  
  // Validate Ethiopian phone number
  static validatePhone(phone) {
    const formatted = this.formatPhone(phone);
    if (!formatted) return false;
    
    const regex = /^\+251[79]\d{8}$/;
    return regex.test(formatted);
  }
  
  // Format ETB currency
  static formatCurrency(amount) {
    return new Intl.NumberFormat('am-ET', {
      style: 'currency',
      currency: 'ETB',
      minimumFractionDigits: 2,
    }).format(amount);
  }
  
  // Ethiopian regions
  static getRegions() {
    return [
      { id: 'addis_ababa', name: 'Addis Ababa', name_am: 'አዲስ አበባ' },
      { id: 'afar', name: 'Afar', name_am: 'አፋር' },
      { id: 'amhara', name: 'Amhara', name_am: 'አማራ' },
      { id: 'benishangul', name: 'Benishangul-Gumuz', name_am: 'ቤኒሻንጉል-ጉሙዝ' },
      { id: 'dire_dawa', name: 'Dire Dawa', name_am: 'ድሬ ዳዋ' },
      { id: 'gambela', name: 'Gambela', name_am: 'ጋምቤላ' },
      { id: 'harari', name: 'Harari', name_am: 'ሐረሪ' },
      { id: 'oromia', name: 'Oromia', name_am: 'ኦሮሚያ' },
      { id: 'sidama', name: 'Sidama', name_am: 'ሲዳማ' },
      { id: 'somali', name: 'Somali', name_am: 'ሶማሌ' },
      { id: 'south_west', name: 'South West Ethiopia', name_am: 'ደቡብ ምዕራብ ኢትዮጵያ' },
      { id: 'snnp', name: 'Southern Nations', name_am: 'ደቡብ ብሔሮች' },
      { id: 'tigray', name: 'Tigray', name_am: 'ትግራይ' }
    ];
  }
  
  // Ethiopian cities by region
  static getCities(regionId) {
    const cities = {
      addis_ababa: [
        'Addis Ababa',
        'ማህተም',
        'ቦሌ',
        'አያት',
        'ኮልፌ ከራንዮ',
        'ንፋስ ስልክ ላፍቶ',
        'አካኪ ቃሊቲ',
        'የካ'
      ],
      oromia: [
        'Adama',
        'Ambo',
        'Bishoftu',
        'Jimma',
        'Shashamane',
        'Woliso',
        'Nekemte',
        'Bale Robe'
      ],
      amhara: [
        'Bahir Dar',
        'Gondar',
        'Dessie',
        'Debre Markos',
        'Debre Birhan',
        'Kombolcha',
        'Woldia'
      ],
      tigray: [
        'Mekele',
        'Adwa',
        'Axum',
        'Shire',
        'Humera',
        'Adigrat'
      ]
    };
    
    return cities[regionId] || [];
  }
  
  // Ethiopian holidays
  static getHolidays(year = new Date().getFullYear()) {
    return [
      {
        date: `${year}-01-07`,
        name: 'Christmas',
        name_am: 'ገና',
        type: 'religious'
      },
      {
        date: `${year}-01-19`,
        name: 'Timkat',
        name_am: 'ጥምቀት',
        type: 'religious'
      },
      {
        date: `${year}-03-02`,
        name: 'Adwa Victory Day',
        name_am: 'አድዋ',
        type: 'national'
      },
      {
        date: `${year}-04-20`,
        name: 'Easter',
        name_am: 'ፋሲካ',
        type: 'religious'
      },
      {
        date: `${year}-05-01`,
        name: 'Labour Day',
        name_am: 'የሰራተኞች ቀን',
        type: 'international'
      },
      {
        date: `${year}-05-28`,
        name: 'Downfall of Derg',
        name_am: 'ደርግ የወደቀበት ቀን',
        type: 'national'
      },
      {
        date: `${year}-09-11`,
        name: 'Ethiopian New Year',
        name_am: 'አዲስ ዓመት',
        type: 'national'
      },
      {
        date: `${year}-09-27`,
        name: 'Meskel',
        name_am: 'መስቀል',
        type: 'religious'
      }
    ];
  }
  
  // Convert Gregorian to Ethiopian date
  static toEthiopianDate(date = new Date()) {
    const gregorian = new Date(date);
    const year = gregorian.getFullYear();
    const month = gregorian.getMonth() + 1;
    const day = gregorian.getDate();
    
    // Simple conversion (approximate)
    const ethiopianYear = year - 8;
    let ethiopianMonth = month;
    let ethiopianDay = day;
    
    // Adjust for Ethiopian calendar
    if (month >= 9) {
      ethiopianMonth = month - 8;
    } else {
      ethiopianMonth = month + 4;
    }
    
    return {
      year: ethiopianYear,
      month: ethiopianMonth,
      day: ethiopianDay,
      formatted: `${ethiopianDay}/${ethiopianMonth}/${ethiopianYear}`,
      formattedAmharic: `${ethiopianDay}፣ ${this.getMonthNameAmharic(ethiopianMonth)} ${ethiopianYear}`
    };
  }
  
  // Get Amharic month names
  static getMonthNameAmharic(month) {
    const months = [
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
      'ጳጉሜ'
    ];
    return months[month - 1] || '';
  }
  
  // Check if date is Ethiopian holiday
  static isHoliday(date = new Date()) {
    const holidays = this.getHolidays(date.getFullYear());
    const dateStr = date.toISOString().split('T')[0];
    
    return holidays.some(holiday => holiday.date === dateStr);
  }
}

module.exports = EthiopianUtils;