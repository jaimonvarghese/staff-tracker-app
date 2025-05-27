import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:staff_tracking_app/views/admin/admin_home.dart';
import 'package:staff_tracking_app/views/auth/login_screen.dart';
import 'package:staff_tracking_app/views/staff/staff_home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists && snapshot.data()!.containsKey('role')) {
        return snapshot['role'] as String;
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return FutureBuilder<String?>(
      future: _getUserRole(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        if (role == 'admin') {
          return const AdminHome();
        } else if (role == 'staff') {
          return const StaffHome();
        } else {
          return const Scaffold(
            body: Center(child: Text("Unknown role or user not found.")),
          );
        }
      },
    );
  }
}
