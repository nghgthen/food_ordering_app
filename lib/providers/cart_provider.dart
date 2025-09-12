import 'package:flutter/foundation.dart';
import '../models/food.dart';

class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + (item.food.price * item.quantity));

  void addToCart(Food food) {
    final index = _items.indexWhere((item) => item.food.id == food.id);
    
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }
    
    notifyListeners();
  }

  void removeFromCart(String foodId) {
    _items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    final index = _items.indexWhere((item) => item.food.id == foodId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}