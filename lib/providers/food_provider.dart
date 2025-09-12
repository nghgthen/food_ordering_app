import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../services/food_service.dart';

class FoodProvider with ChangeNotifier {
  final FoodService foodService;

  FoodProvider({required this.foodService});

  List<Food> _foods = [];
  List<Food> _popularFoods = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Food> get foods => _foods;
  List<Food> get popularFoods => _popularFoods;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Load tất cả món ăn từ Laravel API
  Future<void> loadFoods() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _foods = await foodService.getFoods();
      // Chuẩn hóa categoryId
      _foods = _foods
          .map((f) => Food(
                id: f.id,
                name: f.name,
                image: f.image,
                price: f.price,
                rating: f.rating,
                reviewCount: f.reviewCount,
                description: f.description,
                categoryId: f.categoryId, // dùng id
              ))
          .toList();

      _popularFoods = _foods.where((food) => food.rating >= 4.5).toList();
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lọc món ăn theo categoryId
  List<Food> getFoodsByCategory(int categoryId) {
    if (categoryId == 0) return _foods; // 0 = All
    return _foods.where((food) => food.categoryId == categoryId).toList();
  }

  /// Lấy món ăn theo id
  Food? getFoodById(int id) {
    try {
      return _foods.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Xóa lỗi hiện tại
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
