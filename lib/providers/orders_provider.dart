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

  /// Cập nhật trạng thái đơn hàng (confirm receipt)
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();

      debugPrint("📌 OrdersProvider.updateOrderStatus()");
      debugPrint("   → Order ID = $orderId");
      debugPrint("   → New Status = $status");
      debugPrint("   → Token = $token");

      if (token == null) {
        throw Exception("No authentication token found");
      }

      // ✅ SỬA ĐÂY: Thêm /status vào endpoint
      final url = Uri.parse("${AuthService.baseUrl}/orders/$orderId/status");
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );

      debugPrint("   → Response Status: ${response.statusCode}");
      debugPrint("   → Response Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Order status updated successfully");
        
        // Cập nhật local state ngay lập tức để UI phản hồi nhanh
        final index = _orders.indexWhere((o) => o['id'] == orderId);
        if (index != -1) {
          _orders[index]['status'] = status;
          // Cập nhật cả payment_status nếu cần
          if (_orders[index]['payment_status'] == 'unpaid') {
            _orders[index]['payment_status'] = 'paid';
          }
          notifyListeners();
          debugPrint("   → Local state updated at index $index");
        }
        
        // Sau đó fetch lại từ server để đảm bảo đồng bộ
        await fetchOrders();
      } else {
        debugPrint("❌ Failed to update order: ${response.statusCode}");
        throw Exception("Failed to update order: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Error updating order status: $e");
      rethrow; // throw lại để UI có thể catch và hiển thị error
    }
  }
}