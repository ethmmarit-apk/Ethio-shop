class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check Ethiopian phone formats
    if (digits.startsWith('251') && digits.length == 12) {
      return null;
    }
    
    if (digits.startsWith('0') && digits.length == 10) {
      return null;
    }
    
    if (digits.length == 9) {
      return null;
    }
    
    return 'Please enter a valid Ethiopian phone number';
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  // Maximum length validation
  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName must be less than $max characters';
    }
    return null;
  }

  // Numeric validation
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    
    return null;
  }

  // Price validation
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    if (price > 10000000) {
      return 'Price is too high';
    }
    
    return null;
  }

  // Quantity validation
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    if (quantity > 1000) {
      return 'Quantity is too high';
    }
    
    return null;
  }

  // Ethiopian address validation
  static String? ethiopianAddress({
    String? region,
    String? city,
    String? subcity,
    String? woreda,
    String? kebele,
  }) {
    if (region == null || region.isEmpty) {
      return 'Region is required';
    }
    
    if (city == null || city.isEmpty) {
      return 'City is required';
    }
    
    if (woreda != null && woreda.isNotEmpty) {
      final woredaRegex = RegExp(r'^\d{1,3}$');
      if (!woredaRegex.hasMatch(woreda)) {
        return 'Please enter a valid woreda number';
      }
    }
    
    if (kebele != null && kebele.isNotEmpty) {
      final kebeleRegex = RegExp(r'^\d{1,3}$');
      if (!kebeleRegex.hasMatch(kebele)) {
        return 'Please enter a valid kebele number';
      }
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?' // protocol
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Description validation
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (value.length > 2000) {
      return 'Description must be less than 2000 characters';
    }
    
    return null;
  }

  // Product title validation
  static String? productTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product title is required';
    }
    
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    
    if (value.length > 200) {
      return 'Title must be less than 200 characters';
    }
    
    return null;
  }

  // Category validation
  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    
    return null;
  }

  // OTP validation
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    
    return null;
  }

  // Ethiopian name validation (with Amharic characters)
  static String? ethiopianName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    // Allow Amharic characters and basic Latin
    final nameRegex = RegExp(r'^[\u1200-\u137F\u0041-\u005A\u0061-\u007A\s]+$');
    
    if (!nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Combined validation for multiple fields
  static Map<String, String?> validateForm(Map<String, String> fields) {
    final errors = <String, String?>{};
    
    for (final entry in fields.entries) {
      switch (entry.key) {
        case 'email':
          errors[entry.key] = email(entry.value);
          break;
        case 'password':
          errors[entry.key] = password(entry.value);
          break;
        case 'phone':
          errors[entry.key] = phone(entry.value);
          break;
        case 'firstName':
        case 'lastName':
          errors[entry.key] = name(entry.value);
          break;
        case 'price':
          errors[entry.key] = price(entry.value);
          break;
        case 'quantity':
          errors[entry.key] = quantity(entry.value);
          break;
        case 'title':
          errors[entry.key] = productTitle(entry.value);
          break;
        case 'description':
          errors[entry.key] = description(entry.value);
          break;
        case 'category':
          errors[entry.key] = category(entry.value);
          break;
        default:
          errors[entry.key] = required(entry.value, entry.key);
      }
    }
    
    return errors;
  }

  // Validate if form has errors
  static bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null);
  }

  // Get first error message
  static String? getFirstError(Map<String, String?> errors) {
    for (final error in errors.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}