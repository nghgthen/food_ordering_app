import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/food_card.dart';
import '../food/food_detail_page.dart';
import '../food/popular_foods_page.dart';
import '../food/all_foods_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  // Map category hiển thị → categoryId trong Food
  final Map<String, String> categoryMap = {
    'All': 'All',
    'Burger': 'burger',
    'Pizza': 'pizza',
    'Sushi': 'sushi',
    'Cake': 'cake',
    'Drinks': 'drinks',
    'Salad': 'salad',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoods();
    });
  }

  void _onFoodTap(Food food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(food: food),
      ),
    );
  }

  void _onAddToCart(Food food) {
    context.read<CartProvider>().addToCart(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${food.name} to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    // 👉 Lọc món ăn theo category
    final foods = _selectedCategory == 'All'
        ? foodProvider.foods
        : foodProvider.getFoodsByCategory(categoryMap[_selectedCategory] ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'What would you like to eat?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : foodProvider.error.isNotEmpty
              ? Center(child: Text('Error: ${foodProvider.error}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategories(),
                      const SizedBox(height: 24),
                      _buildPopularFoods(foodProvider),
                      const SizedBox(height: 24),
                      _buildAllFoods(foods),
                    ],
                  ),
                ),
    );
  }

  /// Search bar widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'What would you like to buy?',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
        ),
      ),
    );
  }

  /// Categories widget
  Widget _buildCategories() {
    final categories = categoryMap.keys.toList();
    final icons = [
      Icons.apps,
      Icons.fastfood,
      Icons.local_pizza,
      Icons.set_meal,
      Icons.cake,
      Icons.local_drink,
      Icons.eco,
    ];
    final colors = [
      Colors.grey,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.lightGreen,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors[index].withOpacity(0.6)
                        : colors[index].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: colors[index], width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[index], color: colors[index], size: 28),
                      const SizedBox(height: 6),
                      Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: colors[index],
                        ),
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

  /// Popular Foods widget
  Widget _buildPopularFoods(FoodProvider foodProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Foods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PopularFoodsPage(foods: foodProvider.popularFoods),
                  ),
                );
              },
              child: const Text(
                'See all',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodProvider.popularFoods.length,
            itemBuilder: (context, index) {
              final food = foodProvider.popularFoods[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  right: index == foodProvider.popularFoods.length - 1 ? 0 : 16,
                ),
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

  /// All Foods widget
/// All Foods widget
Widget _buildAllFoods(List<Food> foods) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'All Foods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllFoodsPage(foods: foods),
                ),
              );
            },
            child: const Text(
              'See all',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: foods.length > 4 ? 4 : foods.length, // 👉 hiển thị trước 4 món
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