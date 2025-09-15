import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food.dart';
import '../services/auth_service.dart';

class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  double get subtotal => food.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'food_id': int.parse(food.id),
      'quantity': quantity,
    };
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final AuthService _authService = AuthService();
  final String _baseUrl = "http://127.0.0.1:8000/api";

  List<CartItem> get items => _items;
  
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + (item.food.price * item.quantity));

  // Lấy token từ AuthService
  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Tải giỏ hàng từ API
  Future<void> loadCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        if (kDebugMode) print('No token, skipping cart load');
        return;
      }

      if (kDebugMode) print('Loading cart from API...');

      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Cart API Response: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('Response body: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _items.clear();
          for (var itemData in data['data']['items']) {
            final food = Food.fromJson(itemData['food']);
            _items.add(CartItem(
              food: food,
              quantity: itemData['quantity'],
            ));
          }
          notifyListeners();
          if (kDebugMode) print('Cart loaded: ${_items.length} items');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(Food food) async {
    return addToCartWithQuantity(food, 1);
  }

  // Thêm sản phẩm với số lượng cụ thể
  Future<void> addToCartWithQuantity(Food food, int quantity) async {
    try {
      if (kDebugMode) {
        print('=== START ADD TO CART ===');
        print('Food: ${food.name} (ID: ${food.id})');
        print('Quantity: $quantity');
      }

      final token = await _getToken();
      if (token == null) {
        if (kDebugMode) print('No token found - user not logged in');
        throw Exception('Please login to add to cart');
      }

      if (kDebugMode) print('Token found, making API request...');

      // Gọi API để thêm vào giỏ hàng
      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'food_id': int.parse(food.id),
          'quantity': quantity,
        }),
      );

      if (kDebugMode) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success']) {
          // Cập nhật local state sau khi API thành công
          final index = _items.indexWhere((item) => item.food.id == food.id);
          
          if (index >= 0) {
            _items[index].quantity += quantity;
          } else {
            _items.add(CartItem(food: food, quantity: quantity));
          }
          
          notifyListeners();
          
          if (kDebugMode) {
            print('Successfully added to cart');
            print('Cart items count: ${_items.length}');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to add to cart');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again');
      } else {
        throw Exception('Failed to add to cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to cart: $e');
      }
      throw Exception('Please login to add to cart');
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String foodId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/remove/${int.parse(foodId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _items.removeWhere((item) => item.food.id == foodId);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing from cart: $e');
      }
      _items.removeWhere((item) => item.food.id == foodId);
      notifyListeners();
    }
  }

  // Cập nhật số lượng sản phẩm
  Future<void> updateQuantity(String foodId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.put(
        Uri.parse('$_baseUrl/cart/update/${int.parse(foodId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final index = _items.indexWhere((item) => item.food.id == foodId);
        
        if (index >= 0) {
          if (quantity <= 0) {
            _items.removeAt(index);
          } else {
            _items[index].quantity = quantity;
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating quantity: $e');
      }
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
  }

  // Xóa toàn bộ giỏ hàng - PHƯƠNG THỨC BỊ THIẾU
  Future<void> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/clear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _items.clear();
        notifyListeners();
        if (kDebugMode) print('Cart cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cart: $e');
      }
      // Fallback: clear local cart
      _items.clear();
      notifyListeners();
    }
  }

  // Lấy số lượng của một sản phẩm
  int getQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.food.id == foodId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  // Kiểm tra sản phẩm có trong giỏ hàng không
  bool isInCart(String foodId) {
    return _items.any((item) => item.food.id == foodId);
  }

  // Lấy tổng số sản phẩm distinct (không tính số lượng)
  int get distinctItemCount => _items.length;

  // Kiểm tra giỏ hàng trống
  bool get isEmpty => _items.isEmpty;

  // Kiểm tra giỏ hàng có sản phẩm
  bool get isNotEmpty => _items.isNotEmpty;

  // Hàm kiểm tra kết nối API
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/foods'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Connection test failed: $e');
      }
      return false;
    }
  }

  // Hàm kiểm tra token có hợp lệ không
  Future<bool> validateToken() async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Token validation failed: $e');
      }
      return false;
    }
  }

  // Lấy số lượng giỏ hàng từ API (cho badge)
  Future<int> getCartCountFromAPI() async {
    try {
      final token = await _getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$_baseUrl/cart/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cart count: $e');
      }
      return totalItems; // Fallback to local count
    }
  }
}