import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:staff_tracking_app/features/admin/view/screens/admin_home.dart';
import 'package:staff_tracking_app/features/authentication/services/auth_service.dart';
import 'package:staff_tracking_app/features/authentication/view/screens/login_screen.dart';
import 'package:staff_tracking_app/features/staff/view/screens/staff_home.dart';



class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    User? user = _authService.currentUser;

    if (user == null) {
      return LoginScreen();
    } else {
      return FutureBuilder<bool>(
        future: _authService.isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return AdminHome();
          } else {
            return StaffHome();
          }
        },
      );
    }
  }
}