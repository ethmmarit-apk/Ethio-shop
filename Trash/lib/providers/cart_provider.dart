import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  double _totalAmount = 0.0;
  double _deliveryFee = 0.0;
  double _taxAmount = 0.0;

  List<CartItem> get items => _items;
  double get totalAmount => _totalAmount;
  double get deliveryFee => _deliveryFee;
  double get taxAmount => _taxAmount;
  double get grandTotal => _totalAmount + _deliveryFee + _taxAmount;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  CartProvider() {
    _loadCart();
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Update quantity if product already in cart
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item to cart
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      ));
    }
    
    _calculateTotals();
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _calculateTotals();
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _calculateTotals();
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _totalAmount = 0.0;
    _deliveryFee = 0.0;
    _taxAmount = 0.0;
    _saveCart();
    notifyListeners();
  }

  void applyCoupon(String couponCode, double discountPercent) {
    // Apply coupon logic
    _calculateTotals();
    notifyListeners();
  }

  void updateDeliveryFee(double fee) {
    _deliveryFee = fee;
    _calculateTotals();
    notifyListeners();
  }

  void _calculateTotals() {
    _totalAmount = _items.fold(0.0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
    
    // Calculate tax (15% VAT for Ethiopia)
    _taxAmount = _totalAmount * 0.15;
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toJson()).toList();
      await prefs.setString('cart', jsonEncode(cartData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart: $e');
      }
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      
      if (cartJson != null) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        _calculateTotals();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    }
  }

  Map<String, dynamic> toOrderData() {
    return {
      'items': _items.map((item) => item.toOrderItem()).toList(),
      'subtotal': _totalAmount,
      'deliveryFee': _deliveryFee,
      'taxAmount': _taxAmount,
      'grandTotal': grandTotal,
      'itemCount': itemCount,
    };
  }
}

class CartItem {
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get itemTotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': product.id,
      'productName': product.title,
      'unitPrice': product.price,
      'quantity': quantity,
      'total': itemTotal,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String? category;
  final bool deliveryAvailable;
  final double? deliveryFee;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    this.category,
    this.deliveryAvailable = false,
    this.deliveryFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'category': category,
      'deliveryAvailable': deliveryAvailable,
      'deliveryFee': deliveryFee,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      sellerId: json['sellerId'],
      category: json['category'],
      deliveryAvailable: json['deliveryAvailable'] ?? false,
      deliveryFee: json['deliveryFee'],
    );
  }
}