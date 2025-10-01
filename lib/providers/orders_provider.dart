import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class OrdersProvider with ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;

  /// Lấy danh sách orders từ API
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final userId = await auth.getUserId();

      debugPrint("📌 OrdersProvider.fetchOrders()");
      debugPrint("   → Token = $token");
      debugPrint("   → UserId = $userId");

      if (token == null || userId == null) {
        debugPrint("⚠️ Token hoặc userId null, không thể fetch orders");
        _orders = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse("${AuthService.baseUrl}/orders");
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('orders')) {
          _orders = data['orders'] ?? [];
        } else if (data is List) {
          _orders = data;
        } else {
          _orders = [];
        }

        debugPrint("✅ Orders loaded: ${_orders.length}");
      } else {
        _orders = [];
        debugPrint("❌ Failed to fetch orders: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      _orders = [];
      debugPrint("🔥 Error fetching orders: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Thêm đơn hàng mới vào danh sách (offline ngay lập tức)
  void addOrder(Map<String, dynamic> order) {
    _orders.insert(0, order); // thêm lên đầu danh sách
    notifyListeners();
  }
}
