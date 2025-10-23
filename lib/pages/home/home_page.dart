import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/food_card.dart';
import '../food/food_detail_page.dart';
import '../food/popular_foods_page.dart';
import '../food/all_foods_page.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  final Map<String, int> categoryMap = {
    'All': 0,
    'Burger': 1,
    'Pizza': 2,
    'Sushi': 3,
    'Cake': 4,
    'Drinks': 5,
    'Salad': 6,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<FoodProvider>().loadFoods();
      } catch (e) {
        debugPrint('Error loading foods: $e');
      }
    });
  }

  void _onFoodTap(Food food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodDetailPage(food: food)),
    );
  }

  // ✅ THÊM VÀO GIỎ - KHÔNG LOGIN
  void _onAddToCart(Food food) {
    context.read<CartProvider>().addToCart(food);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ ${food.name} đã thêm vào giỏ hàng'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final loc = AppLocalizations.of(context);

    final selectedId = categoryMap[_selectedCategory] ?? 0;
    final foods = (selectedId == 0)
        ? foodProvider.foods
        : foodProvider.getFoodsByCategory(selectedId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : CustomScrollView(
              slivers: [
                // App Bar với Logo
                SliverAppBar(
                  expandedHeight: 140,
                  floating: true,
                  pinned: false,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                      child: Row(
                        children: [
                          // ✅ LOGO
                          Image.asset(
                            'assets/images/foods/logo.png',
                            height: 50,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.restaurant, color: Colors.white, size: 30),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chào mừng! 👋',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.t('what_would_you_like_to_eat'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _buildSearchBar(),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: _buildCategories(),
                  ),
                ),

                // Popular Foods
                if (foodProvider.popularFoods.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 24),
                      child: _buildPopularFoods(foodProvider),
                    ),
                  ),

                // All Foods
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildAllFoods(foods),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm món ăn...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFFE53935), size: 22),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = categoryMap.keys.toList();
    final icons = [
      Icons.apps_rounded,
      Icons.lunch_dining_rounded,
      Icons.local_pizza_rounded,
      Icons.set_meal_rounded,
      Icons.cake_rounded,
      Icons.local_cafe_rounded,
      Icons.eco_rounded,
    ];
    final colors = [
      const Color(0xFF757575),
      const Color(0xFFFF9800),
      const Color(0xFFE53935),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [colors[index], colors[index].withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors[index] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: colors[index].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        color: isSelected ? Colors.white : colors[index],
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: isSelected ? Colors.white : colors[index],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularFoods(FoodProvider foodProvider) {
    final popular = foodProvider.popularFoods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Color(0xFFE53935), size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Phổ biến',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PopularFoodsPage(foods: popular)),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popular.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final food = popular[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: FoodCard(
                  food: food,
                  onTap: () => _onFoodTap(food),
                  onAdd: () => _onAddToCart(food),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllFoods(List<Food> foods) {
    if (foods.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.food_bank_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Không có món ăn',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Tất cả món ăn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return FoodCard(
              food: food,
              onTap: () => _onFoodTap(food),
              onAdd: () => _onAddToCart(food),
            );
          },
        ),
      ],
    );
  }
}