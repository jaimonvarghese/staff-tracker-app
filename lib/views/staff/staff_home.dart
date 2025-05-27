import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/views/staff/profile_screen.dart';
import 'package:staff_tracking_app/views/staff/punch_history_screen.dart';
import 'package:staff_tracking_app/views/staff/punch_screen.dart';
import 'package:staff_tracking_app/views/staff/staff_work_summary_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class StaffHome extends ConsumerWidget {
  const StaffHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.watch(authViewModelProvider);
    final user = authVM.user;

    return Scaffold(
      appBar: AppBar(
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, ${user?.name ?? "Staff"}!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PunchScreen(userId: user?.uid ?? ''),
                  ),
                );
              },
              child: const Text('Punch In / Out'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffWorkSummaryScreen(userId: user?.uid ?? ''),
                  ),
                );
              },
              child: const Text('View Today\'s Summary'),
            ),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffProfileScreen(userId: authVM.user?.uid ?? ''),
      ),
    );
  },
  child: const Text("My Profile"),
),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PunchHistoryScreen(userId: user?.uid ?? ''),
      ),
    );
  },
  child: const Text("My Punch History"),
),

          ],
        ),
      ),
    );
  }
}
