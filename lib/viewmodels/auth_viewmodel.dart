import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  AppUser? user;
  bool isLoading = false;

  AuthViewModel(this._authService);

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authService.login(email, password);
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role, 
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authService.signup(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _authService.logout();
    user = null;
    notifyListeners();
  }
}
