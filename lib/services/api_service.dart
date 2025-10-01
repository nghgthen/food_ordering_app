// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://172.20.10.3:8000/api"; // đổi theo server

  Future<bool> createOrder(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }
}
