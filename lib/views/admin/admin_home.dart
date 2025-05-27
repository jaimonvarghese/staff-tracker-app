import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/views/admin/assign_staff_screen.dart';
import 'package:staff_tracking_app/views/admin/create_office_screen.dart';
import 'package:staff_tracking_app/views/admin/movement_history_screen.dart';
import 'package:staff_tracking_app/views/admin/staff_live_location_screen.dart';
import 'package:staff_tracking_app/views/admin/working_hours_report_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminHome extends ConsumerWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.watch(authViewModelProvider);
    final user = authVM.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              'Welcome, ${user?.name ?? "Admin"}!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateOfficeScreen()),
                );
              },
              child: const Text('Create Office Location'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkingHoursReportScreen(),
                  ),
                );
              },
              child: const Text('Daily Working Hours'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssignStaffScreen()),
                );
              },
              child: const Text('Assign Staff to Office'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StaffLiveLocationScreen(),
                  ),
                );
              },
              child: const Text('View Staff Location'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MovementHistoryScreen(),
                  ),
                );
              },
              child: const Text('View Movement History'),
            ),
          ],
        ),
      ),
    );
  }
}
