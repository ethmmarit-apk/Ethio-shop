import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_shop/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Product creates correctly from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Product',
        'description': 'Test Description',
        'price': 100.0,
        'imageUrl': 'https://example.com/image.jpg',
        'sellerId': 'seller1',
        'category': 'Electronics',
        'condition': 'new',
        'location': 'Addis Ababa',
        'rating': 4.5,
        'reviewCount': 10,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.title, 'Test Product');
      expect(product.price, 100.0);
      expect(product.category, 'Electronics');
      expect(product.rating, 4.5);
    });

    test('Product converts to JSON correctly', () {
      final product = Product(
        id: '1',
        title: 'Test Product',
        description: 'Test Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        sellerId: 'seller1',
        category: 'Electronics',
        condition: 'new',
        location: 'Addis Ababa',
        rating: 4.5,
        reviewCount: 10,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      final json = product.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Product');
      expect(json['price'], 100.0);
      expect(json['category'], 'Electronics');
      expect(json['rating'], 4.5);
    });

    test('Product price formatting in ETB', () {
      final product = Product(
        id: '1',
        title: 'Test',
        description: 'Test',
        price: 1500.50,
        imageUrl: '',
        sellerId: '1',
        category: 'Test',
        condition: 'new',
        location: 'Addis Ababa',
        rating: 5.0,
        reviewCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.formattedPrice, 'ETB 1,500.50');
    });
  });
}