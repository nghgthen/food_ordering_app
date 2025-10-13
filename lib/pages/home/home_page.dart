import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/food_card.dart';
import '../food/food_detail_page.dart';
import '../food/popular_foods_page.dart';
import '../food/all_foods_page.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_page.dart'; // THÊM IMPORT NÀY

class HomePage extends StatefulWidget {
  final VoidCallback? onRequestLogin; // CALLBACK ĐỂ MỞ LOGIN
  const HomePage({super.key, this.onRequestLogin});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  // Map tên category hiển thị -> categoryId
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
        final foods = context.read<FoodProvider>().foods;
        print('Foods loaded: ${foods.length}');
        for (var f in foods) {
          print(' - ${f.name} (categoryId: ${f.categoryId})');
        }
      } catch (e) {
        print('Error loading foods: $e');
      }
    });
  }

  void _onFoodTap(Food food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodDetailPage(food: food)),
    );
  }

  void _onAddToCart(Food food) async {
    final auth = AuthService();
    final isLoggedIn = await auth.isLoggedIn;
    final loc = AppLocalizations.of(context);

    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.t('login_required')),
          content: Text(loc.t('login_to_add_cart')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // ĐÓNG DIALOG TRƯỚC
                _navigateToLogin(); // ĐIỀU HƯỚNG ĐẾN LOGIN
              },
              child: Text(loc.t('login')),
            ),
          ],
        ),
      );
      return;
    }

    context.read<CartProvider>().addToCart(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${loc.t('added')} ${food.name} ${loc.t('to_cart')}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // HÀM MỚI: XỬ LÝ ĐIỀU HƯỚNG ĐẾN LOGIN PAGE
  void _navigateToLogin() {
    if (widget.onRequestLogin != null) {
      // SỬ DỤNG CALLBACK TỪ PARENT NẾU CÓ
      widget.onRequestLogin!();
    } else {
// FALLBACK: TỰ ĐIỀU HƯỚNG NẾU KHÔNG CÓ CALLBACK
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final loc = AppLocalizations.of(context);

    // Lọc món theo categoryId
    final selectedId = categoryMap[_selectedCategory] ?? 0;
    final foods = (selectedId == 0)
        ? foodProvider.foods
        : foodProvider.getFoodsByCategory(selectedId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.t('what_would_you_like_to_eat'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : foods.isEmpty
              ? Center(child: Text(loc.t('no_foods_available')))
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

  Widget _buildSearchBar() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: loc.t('what_would_you_like_to_buy'),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final loc = AppLocalizations.of(context);
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
        Text(
          loc.t('categories'),
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                onTap: () => setState(() => _selectedCategory = category),
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
                        loc.t('category_${category.toLowerCase()}'),
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

  Widget _buildPopularFoods(FoodProvider foodProvider) {
    final loc = AppLocalizations.of(context);
    final popular = foodProvider.popularFoods;
    if (popular.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.t('popular_foods'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PopularFoodsPage(foods: popular),
                  ),
                );
              },
              child: Text(
                loc.t('see_all'),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popular.length,
            itemBuilder: (context, index) {
              final food = popular[index];
              return Container(
                width: 180,
                margin: EdgeInsets.only(
                  right: index == popular.length - 1 ? 0 : 16,
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

  Widget _buildAllFoods(List<Food> foods) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.t('all_foods'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllFoodsPage(foods: foods)),
                );
              },
              child: Text(
                loc.t('see_all'),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
          itemCount: foods.length, // hiển thị tất cả món
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