import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/features/staff/providers/staff_provider.dart';

class PunchScreen extends ConsumerWidget {
  final String userId;

  const PunchScreen({Key? key, required this.userId}) : super(key: key);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(staffViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Punch In / Out"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            viewModel.isPunchedIn
                ? ElevatedButton.icon(
                  onPressed: () async {
                    final error = await ref
                        .read(staffViewModelProvider)
                        .punchOut(userId);
                    if (error != null) {
                      _showMessage(context, error);
                    } else {
                      _showMessage(context, "Punched out successfully.");
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Punch Out"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                )
                : ElevatedButton.icon(
                  onPressed: () async {
                    final error = await ref
                        .read(staffViewModelProvider)
                        .punchIn(userId);
                    if (error != null) {
                      _showMessage(context, error);
                    } else {
                      _showMessage(context, "Punched in successfully.");
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Punch In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
