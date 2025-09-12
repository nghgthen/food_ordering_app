import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../providers/cart_provider.dart';

class FoodDetailPage extends StatelessWidget {
  final Food food;

  const FoodDetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.name),
        backgroundColor: const Color.fromARGB(255, 238, 206, 204),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh món ăn
            food.image.isNotEmpty
                ? Image.asset(
                    food.image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                  ),

            const SizedBox(height: 16),

            // Tên món ăn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                food.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Giá + Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '\$${food.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:const Color.fromARGB(255, 238, 206, 204),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${food.rating} (${food.reviewCount} reviews)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mô tả
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                food.description.isNotEmpty
                    ? food.description
                    : "No description available.",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Button thêm vào giỏ
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 238, 206, 204),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.read<CartProvider>().addToCart(food);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Added ${food.name} to cart")),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
