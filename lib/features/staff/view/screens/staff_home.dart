import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/features/authentication/view/screens/login_screen.dart';

import 'package:staff_tracking_app/features/staff/view/screens/punch_screen.dart';
import 'package:staff_tracking_app/features/staff/view/screens/staff_work_summary_screen.dart';
import '../../../authentication/providers/auth_provider.dart';

class StaffHome extends ConsumerWidget {
  const StaffHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.watch(authViewModelProvider);
    final user = authVM.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authViewModelProvider).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavButton(
              context,
              label: 'Punch In / Out',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PunchScreen(userId: user.uid),
                    ),
                  ),
            ),
            _buildNavButton(
              context,
              label: "View Today's Summary",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffWorkSummaryScreen(userId: user.uid),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
