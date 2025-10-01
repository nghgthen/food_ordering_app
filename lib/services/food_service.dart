import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class FoodService {
  // URL base của Laravel API
  static const String baseUrl = 'http://172.20.10.3:8000/api';

  // Lấy tất cả foods từ API
  Future<List<Food>> getFoods() async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Food.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  // Lấy foods theo category
  Future<List<Food>> getFoodsByCategory(String categoryId) async {
    if (categoryId == 'all') {
      return getFoods();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/foods/category/$categoryId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Food.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load foods by category');
    }
  }

  // Tìm kiếm foods theo tên
  Future<List<Food>> searchFoods(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods?search=$keyword'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Food.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search foods');
    }
  }
}
