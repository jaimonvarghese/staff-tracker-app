// screens/staff_work_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:staff_tracking_app/features/staff/providers/staff_provider.dart';

class StaffWorkSummaryScreen extends ConsumerWidget {
  final String userId;
  const StaffWorkSummaryScreen({Key? key, required this.userId})
    : super(key: key);

  String formatDuration(Duration d) =>
      "${d.inHours}h ${d.inMinutes.remainder(60)}m";

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(staffViewModelProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      viewModel.updateDate(picked, userId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(staffViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Daily Summary"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Date:", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _pickDate(context, ref),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(viewModel.selectedDate),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Total Working Hours: ${formatDuration(viewModel.totalDuration)}",
              style: TextStyle(color: Colors.white),
            ),
            const Divider(height: 32),
            Expanded(
              child:
                  viewModel.punches.isEmpty
                      ? const Center(
                        child: Text(
                          "No punch data found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : ListView.separated(
                        itemCount: viewModel.punches.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = viewModel.punches[index];
                          final inTime = DateTime.parse(entry['in']);
                          final outTime =
                              entry['out'] != null
                                  ? DateTime.parse(entry['out'])
                                  : null;

                          final duration =
                              outTime?.difference(inTime) ?? Duration.zero;

                          return ListTile(
                            leading: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                            ),
                            title: Text(
                              "In: ${DateFormat.Hm().format(inTime.toLocal())}",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle:
                                outTime != null
                                    ? Text(
                                      "Out: ${DateFormat.Hm().format(outTime.toLocal())}",
                                      style: TextStyle(color: Colors.white),
                                    )
                                    : const Text(
                                      "Not yet punched out",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            trailing:
                                outTime != null
                                    ? Text(
                                      formatDuration(duration),
                                      style: TextStyle(color: Colors.white),
                                    )
                                    : null,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
