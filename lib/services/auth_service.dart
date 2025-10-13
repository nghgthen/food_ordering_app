import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String baseUrl =
      "http://10.240.165.238:8000/api"; // ⚠️ Đổi thành IP thật khi chạy device

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
          await prefs.setString("userEmail", email);

          // Nếu login trả về luôn user.id thì lưu lại
          if (data["user"]?["id"] != null) {
            await prefs.setInt("userId", data["user"]["id"]);
            debugPrint("✅ Saved userId from login = ${data['user']['id']}");
          }

          // Lấy thêm thông tin user để chắc chắn có userId
          await _fetchAndSaveUserInfo(data["token"]);
          return true;
        }
      }
      debugPrint("❌ Login failed: ${res.statusCode} - ${res.body}");
      return false;
    } catch (e) {
      debugPrint("🔥 Login error: $e");
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
          "name": email.split("@")[0],
          "email": email,
          "password": password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
          await prefs.setString("userEmail", email);

          if (data["user"]?["id"] != null) {
            await prefs.setInt("userId", data["user"]["id"]);
            debugPrint("✅ Saved userId from register = ${data['user']['id']}");
          }

          await _fetchAndSaveUserInfo(data["token"]);
          return true;
        }
      }
      debugPrint("❌ Register failed: ${res.statusCode} - ${res.body}");
      return false;
    } catch (e) {
      debugPrint("🔥 Register error: $e");
      return false;
    }
  }

  /// 🚪 Đăng xuất
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse("$baseUrl/logout"),
          headers: {"Authorization": "Bearer $token"},
        );
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("✅ Logged out & cleared local storage");
  }

  /// 📦 Lấy token hiện tại
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// ✅ Kiểm tra trạng thái đăng nhập
  Future<bool> get isLoggedIn async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 📧 Lấy email người dùng hiện tại
  Future<String?> get userEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  /// 👤 Lấy userId (dùng cho Orders)
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  /// 🌐 Headers có Bearer token
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) return {};
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  /// 🔄 Gọi API /user để lấy thông tin user và lưu vào local
  Future<void> _fetchAndSaveUserInfo(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/user"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["id"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("userId", data["id"]);
          debugPrint("✅ Saved userId from /user = ${data['id']}");
        }
      } else {
        debugPrint("❌ /user failed: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      debugPrint("🔥 Error fetching user info: $e");
    }
  }
}
