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

  List<Food> get foods => _foods;
  List<Food> get popularFoods => _popularFoods;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Load tất cả món ăn
  Future<void> loadFoods() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _foods = await foodService.getFoods();
      _popularFoods = _foods.where((food) => food.rating >= 4.5).toList();
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lọc món ăn theo category
  List<Food> getFoodsByCategory(String categoryId) {
    return _foods.where((food) => food.categoryId == categoryId).toList();
  }

  /// Tìm món theo id
  Food? getFoodById(String id) {
    try {
      return _foods.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Reset lỗi
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
