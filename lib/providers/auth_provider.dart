import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Provides an instance of AuthService for authentication-related logic
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides an instance of AuthViewModel for managing user auth state
final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService);
});
