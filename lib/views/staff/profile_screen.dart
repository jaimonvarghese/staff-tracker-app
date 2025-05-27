import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffProfileScreen extends StatelessWidget {
  final String userId;
  const StaffProfileScreen({super.key, required this.userId});

  Future<Map<String, dynamic>?> _getUserData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 16),
                Text("Name: ${data['name']}"),
                Text("Email: ${data['email']}"),
                Text("Role: ${data['role']}"),
                Text("Assigned Office ID: ${data['assignedOfficeId'] ?? 'Not assigned'}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
