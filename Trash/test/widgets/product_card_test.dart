import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_shop/widgets/product_card.dart';

void main() {
  group('ProductCard Widget Tests', () {
    final testProduct = {
      'id': '1',
      'title': 'iPhone 14 Pro',
      'description': 'Brand new iPhone 14 Pro 256GB',
      'price': 45000.0,
      'image': 'https://picsum.photos/200',
      'location': 'Addis Ababa',
      'rating': 4.8,
      'seller': 'Tech Hub Ethiopia',
      'status': 'new',
    };

    testWidgets('ProductCard displays product information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify product title is displayed
      expect(find.text('iPhone 14 Pro'), findsOneWidget);

      // Verify price is displayed in ETB format
      expect(find.text('ETB 45,000.00'), findsOneWidget);

      // Verify location is displayed
      expect(find.text('Addis Ababa'), findsOneWidget);

      // Verify seller is displayed
      expect(find.text('Tech Hub Ethiopia'), findsOneWidget);

      // Verify rating is displayed
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('ProductCard shows new badge for new products',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify new badge is shown
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('ProductCard shows different status badges',
        (WidgetTester tester) async {
      final usedProduct = Map<String, dynamic>.from(testProduct)
        ..['status'] = 'used';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: usedProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Used'), findsOneWidget);
    });

    testWidgets('ProductCard shows favorite button when callback provided',
        (WidgetTester tester) async {
      bool isFavorite = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {},
              onFavorite: () {
                isFavorite = !isFavorite;
              },
              isFavorite: isFavorite,
            ),
          ),
        ),
      );

      // Verify favorite button is present
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('ProductCard favorite button toggles',
        (WidgetTester tester) async {
      bool isFavorite = false;
      void toggleFavorite() {
        isFavorite = !isFavorite;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ProductCard(
                  product: testProduct,
                  onTap: () {},
                  onFavorite: () {
                    setState(() {
                      toggleFavorite();
                    });
                  },
                  isFavorite: isFavorite,
                );
              },
            ),
          ),
        ),
      );

      // Initially shows unfilled heart
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // Now should show filled heart
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('ProductCard tap triggers callback',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the product card
      await tester.tap(find.byType(ProductCard));
      await tester.pump();

      // Verify callback was called
      expect(wasTapped, true);
    });

    testWidgets('ProductCard shows correct image placeholder on error',
        (WidgetTester tester) async {
      final productWithInvalidImage = Map<String, dynamic>.from(testProduct)
        ..['image'] = 'invalid-url';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: productWithInvalidImage,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should show image placeholder
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('ProductCard truncates long titles',
        (WidgetTester tester) async {
      final productWithLongTitle = Map<String, dynamic>.from(testProduct)
        ..['title'] = 'Very Long Product Title That Should Be Truncated '
            'Because It Exceeds Two Lines of Text';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force truncation
              child: ProductCard(
                product: productWithLongTitle,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Title should be displayed (truncated)
      expect(find.textContaining('Very Long Product Title'), findsOneWidget);
    });

    testWidgets('ProductCard shows "Add to Cart" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('ProductCard has proper styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should have rounded corners
      final card = tester.widget<Container>(find.byType(Container).first);
      final decoration = card.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);

      // Should have shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, true);
    });
  });

  group('ProductGridView Tests', () {
    final testProducts = [
      {
        'id': '1',
        'title': 'Product 1',
        'price': 100.0,
        'image': 'https://picsum.photos/200',
        'location': 'Addis Ababa',
      },
      {
        'id': '2',
        'title': 'Product 2',
        'price': 200.0,
        'image': 'https://picsum.photos/201',
        'location': 'Addis Ababa',
      },
    ];

    testWidgets('ProductGridView displays multiple products',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridView(
              products: testProducts,
              onProductTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
      expect(find.text('ETB 100.00'), findsOneWidget);
      expect(find.text('ETB 200.00'), findsOneWidget);
    });

    testWidgets('ProductGridView shows loading indicator when hasMore',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridView(
              products: testProducts,
              onProductTap: (_) {},
              hasMore: true,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}