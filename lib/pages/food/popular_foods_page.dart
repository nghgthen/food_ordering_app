import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../widgets/food_card.dart';
import '../../providers/cart_provider.dart';
import 'food_detail_page.dart';

class PopularFoodsPage extends StatelessWidget {
  final List<Food> foods;

  const PopularFoodsPage({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Foods'),
        backgroundColor:const Color.fromARGB(255, 238, 206, 204),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return FoodCard(
            food: food,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodDetailPage(food: food),
                ),
              );
            },
            onAdd: () {
              context.read<CartProvider>().addToCart(food);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${food.name} to cart')),
              );
            },
          );
        },
      ),
    );
  }
}
