import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api"; // đổi thành IP thật khi chạy trên device

  /// 🔑 Đăng nhập
  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
          // Lưu thêm email khi đăng nhập thành công
          await prefs.setString("userEmail", email);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 📝 Đăng ký
  Future<bool> register(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/register");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": email.split("@")[0], // tạo tạm từ email
          "email": email,
          "password": password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
          // Lưu thêm email khi đăng ký thành công
          await prefs.setString("userEmail", email);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 🚪 Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userEmail"); // Xóa email khi đăng xuất
  }

  /// 📦 Lấy token hiện tại
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// ✅ Kiểm tra trạng thái đăng nhập
  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return token != null && token.isNotEmpty;
  }

  /// 📧 Lấy email người dùng hiện tại
  Future<String?> get userEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }
}