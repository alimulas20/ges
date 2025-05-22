// login/login_view_model.dart
import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _loading = false;

  bool get isLoading => _loading;

  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.login(LoginModel(username: username, password: password));
      return true;
    } catch (_) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
