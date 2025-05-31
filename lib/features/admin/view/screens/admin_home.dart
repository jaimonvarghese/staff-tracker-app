import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/features/admin/view/screens/assign_staff_screen.dart';
import 'package:staff_tracking_app/features/admin/view/screens/create_staff_screen.dart';

import 'package:staff_tracking_app/features/admin/view/screens/staff_live_location_screen.dart';
import 'package:staff_tracking_app/features/admin/view/screens/working_hours_report_screen.dart';
import 'package:staff_tracking_app/features/admin/view/widgets/admin_Item_box_container.dart';
import 'package:staff_tracking_app/features/admin/view/widgets/admin_home_button.dart';
import 'package:staff_tracking_app/features/authentication/providers/auth_provider.dart';
import 'package:staff_tracking_app/features/authentication/view/screens/login_screen.dart';


import 'create_office_screen.dart';

class AdminHome extends ConsumerWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final authVM = ref.read(authViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authVM.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AdminItemBoxContainer(
              text: 'Assign staff to office',
              buttonText: 'Assign staff to office',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignStaffScreen(),
                    ),
                  ),
            ),
            SizedBox(height: 15),
            AdminItemBoxContainer(
              text: 'Live location of staff',
              buttonText: 'Track Live Location',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffLiveLocationScreen(),
                    ),
                  ),
            ),
            SizedBox(height: 15),
            
            AdminItemBoxContainer(
              text: 'Total Workin Hours of  staff',
              buttonText: 'Total Workin Hours of  staff',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkingHoursReportScreen(),
                    ),
                  ),
            ),
            SizedBox(height: 25),
            AdminHomeButton(
              buttonText: "Create Office",
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateOfficeScreen()),
                  ),
            ),
            SizedBox(height: 10),
            AdminHomeButton(
              buttonText: "Create Staff",
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateStaffScreen()),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
