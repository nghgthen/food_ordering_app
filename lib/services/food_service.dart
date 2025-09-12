import '../models/food.dart';

class FoodService {
  // Trong thực tế, sẽ thay bằng API call đến Laravel backend
  Future<List<Food>> getFoods() async {
    // Giả lập độ trễ như khi gọi API
    await Future.delayed(const Duration(seconds: 1));

    return [
      Food(
        id: '1',
        name: 'Fried Egg',
        image: 'assets/images/foods/fried_egg.png',
        price: 15.06,
        rating: 4.3,
        reviewCount: 2005,
        description: 'Delicious fried egg with special sauce',
        categoryId: 'salad',
      ),
      Food(
        id: '2',
        name: 'Mixed Vegetable',
        image: 'assets/images/foods/mixed_vegetable.png',
        price: 17.03,
        rating: 4.3,
        reviewCount: 100,
        description: 'Fresh mixed vegetables with special dressing',
        categoryId: 'salad',
      ),
      Food(
        id: '3',
        name: 'Burger',
        image: 'assets/images/foods/burger.png',
        price: 5.99,
        rating: 4.9,
        reviewCount: 1500,
        description: 'Juicy beef burger with cheese and vegetables',
        categoryId: 'burger',
      ),
      Food(
        id: '4',
        name: 'Via Napoli Pizzeria',
        image: 'assets/images/foods/pizza.png',
        price: 8.5,
        rating: 4.8,
        reviewCount: 1200,
        description: 'Delicious pizza with various toppings',
        categoryId: 'pizza',
      ),
    ];
  }

  Future<List<Food>> getFoodsByCategory(String categoryId) async {
    final allFoods = await getFoods();
    return allFoods.where((food) => food.categoryId == categoryId).toList();
  }
}
