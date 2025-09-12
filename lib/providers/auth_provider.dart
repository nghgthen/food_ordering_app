import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _email;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get email => _email;
  String? get error => _error;

  Future<void> checkLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _isLoggedIn = await _authService.isLoggedIn;
      if (_isLoggedIn) {
        _email = await _authService.userEmail;
      } else {
        _email = null;
      }
    } catch (e) {
      _error = 'Failed to check login status';
      _isLoggedIn = false;
      _email = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final ok = await _authService.login(email, password);
      if (ok) {
        _isLoggedIn = true;
        _email = await _authService.userEmail;
        _error = null;
      } else {
        _error = 'Invalid email or password';
      }
      notifyListeners();
      return ok;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoggedIn = false;
      _email = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _email = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}