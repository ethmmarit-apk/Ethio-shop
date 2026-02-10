import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ethio_shop/providers/auth_provider.dart';
import 'package:ethio_shop/providers/cart_provider.dart';
import 'package:ethio_shop/providers/language_provider.dart';
import 'package:ethio_shop/widgets/product_card.dart';
import 'package:ethio_shop/widgets/category_chip.dart';
import 'package:ethio_shop/widgets/search_bar.dart';
import 'package:ethio_shop/utils/ethiopian_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'All', 'icon': Icons.category},
    {'id': 1, 'name': 'Electronics', 'icon': Icons.electrical_services},
    {'id': 2, 'name': 'Fashion', 'icon': Icons.shopping_bag},
    {'id': 3, 'name': 'Home', 'icon': Icons.home},
    {'id': 4, 'name': 'Vehicles', 'icon': Icons.directions_car},
    {'id': 5, 'name': 'Real Estate', 'icon': Icons.apartment},
    {'id': 6, 'name': 'Jobs', 'icon': Icons.work},
    {'id': 7, 'name': 'Services', 'icon': Icons.handyman},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'title': 'iPhone 14 Pro Max',
      'description': 'Brand new iPhone 14 Pro Max 256GB',
      'price': 45000.00,
      'image': 'https://picsum.photos/200',
      'location': 'Addis Ababa',
      'rating': 4.8,
      'seller': 'Tech Hub Ethiopia',
    },
    {
      'id': '2',
      'title': 'ሸሚዝ እና ታሪክ',
      'description': 'አዲስ የባቡር ሸሚዝ እና ታሪክ',
      'price': 850.00,
      'image': 'https://picsum.photos/201',
      'location': 'Addis Ababa',
      'rating': 4.5,
      'seller': 'Habesha Fashion',
    },
    {
      'id': '3',
      'title': '5 Seater Sofa Set',
      'description': 'Modern leather sofa set, excellent condition',
      'price': 12500.00,
      'image': 'https://picsum.photos/202',
      'location': 'Addis Ababa',
      'rating': 4.7,
      'seller': 'Home Decor Ethiopia',
    },
    {
      'id': '4',
      'title': 'Toyota Corolla 2018',
      'description': 'Automatic transmission, well maintained',
      'price': 450000.00,
      'image': 'https://picsum.photos/203',
      'location': 'Addis Ababa',
      'rating': 4.9,
      'seller': 'Auto Market',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('appTitle') ?? 'Ethio Shop',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: const Icon(Icons.shopping_cart),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // User profile
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const CircleAvatar(
              backgroundImage: NetworkImage('https://picsum.photos/100'),
              radius: 16,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  onSearch: (query) {},
                  hintText: languageProvider.translate('searchHint') ??
                      'Search products...',
                ),
              ),

              // Location Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.translate('deliveryTo') ??
                                'Delivery to',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            'Addis Ababa, Bole',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/location'),
                      child: Text(
                        languageProvider.translate('change') ?? 'Change',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('categories') ?? 'Categories',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return CategoryChip(
                            label: category['name'] as String,
                            icon: category['icon'] as IconData,
                            isSelected: _selectedCategory == category['id'],
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['id'] as int;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Featured Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.translate('featuredProducts') ??
                              'Featured Products',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/products'),
                          child: Text(
                            languageProvider.translate('seeAll') ?? 'See All',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Featured products grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/product-details',
                            arguments: product,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Banner Ad
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 20,
                      bottom: 20,
                      child: Image.asset(
                        'assets/images/discount.png',
                        width: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            languageProvider.translate('specialOffer') ??
                                'Special Offer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            languageProvider.translate('discountText') ??
                                'Get up to 50% off on selected items',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              languageProvider.translate('shopNow') ?? 'Shop Now',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Recently Viewed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('recentlyViewed') ??
                          'Recently Viewed',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _products.take(3).length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Container(
                            width: 150,
                            margin: EdgeInsets.only(
                              right: index < 2 ? 12 : 0,
                            ),
                            child: ProductCard(
                              product: product,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/product-details',
                                arguments: product,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/sell'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushNamed(context, '/browse');
            break;
          case 2:
            Navigator.pushNamed(context, '/chat');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}