import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkingHoursReportScreen extends ConsumerStatefulWidget {
  const WorkingHoursReportScreen({super.key});

  @override
  ConsumerState<WorkingHoursReportScreen> createState() =>
      _WorkingHoursReportScreenState();
}

class _WorkingHoursReportScreenState extends ConsumerState<WorkingHoursReportScreen> {
  String? selectedStaffId;
  DateTime selectedDate = DateTime.now();
  Duration totalHours = Duration.zero;
  List<Map<String, dynamic>> punches = [];

  /// Fetch list of staff users
  Future<List<QueryDocumentSnapshot>> _getStaffList() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'staff')
            .get();
    return snapshot.docs;
  }

  /// Fetch working hours and punch entries
  Future<void> _fetchWorkingHours() async {
    if (selectedStaffId == null) return;

    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final doc =
        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(selectedStaffId)
            .collection('logs')
            .doc(dateStr)
            .get();

    if (!doc.exists) {
      setState(() {
        punches = [];
        totalHours = Duration.zero;
      });
      _showMessage("No punch data found for this date.");
      return;
    }

    final data = doc.data()!;
    final entries = List<Map<String, dynamic>>.from(data['entries']);
    Duration total = Duration.zero;

    for (var entry in entries) {
      if (entry['in'] != null && entry['out'] != null) {
        final inTime = DateTime.parse(entry['in']);
        final outTime = DateTime.parse(entry['out']);
        total += outTime.difference(inTime);
      }
    }

    setState(() {
      punches = entries;
      totalHours = total;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      await _fetchWorkingHours();
    }
  }

  String formatDuration(Duration d) =>
      "${d.inHours}h ${d.inMinutes.remainder(60)}m";

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Working Hours Report"),
        backgroundColor: Colors.black,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Staff Dropdown
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _getStaffList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();

                final staffList = snapshot.data!;
                return DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF2C2C2C),
                  value: selectedStaffId,
                  hint: const Text(
                    "Select Staff",
                    style: TextStyle(color: Colors.white54),
                  ),
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items:
                      staffList.map((doc) {
                        final name = doc['name'] ?? 'Unnamed';
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(
                            name,
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }).toList(),
                  onChanged: (val) async {
                    setState(() => selectedStaffId = val);
                    await _fetchWorkingHours();
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            /// Date Picker
            Row(
              children: [
                const Text(
                  "Date:",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    "${selectedDate.toLocal()}".split(" ")[0],
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),

            const Divider(),

            /// Export Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Total Working Time: ${formatDuration(totalHours)}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "Punch Entries:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            /// Punch Entries List
            Expanded(
              child:
                  punches.isEmpty
                      ? const Center(
                        child: Text(
                          "No entries found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : ListView.separated(
                        itemCount: punches.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = punches[index];
                          final inTime = DateTime.parse(entry['in']);
                          final outTime = DateTime.parse(entry['out']);
                          final duration = outTime.difference(inTime);

                          return ListTile(
                            title: Text(
                              "In: ${inTime.toLocal()}",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Out: ${outTime.toLocal()}",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              formatDuration(duration),
                              style: TextStyle(color: Colors.white),
                            ),
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
