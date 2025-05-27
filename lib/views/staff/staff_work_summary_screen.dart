import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffWorkSummaryScreen extends StatefulWidget {
  final String userId;
  const StaffWorkSummaryScreen({super.key, required this.userId});

  @override
  State<StaffWorkSummaryScreen> createState() => _StaffWorkSummaryScreenState();
}

class _StaffWorkSummaryScreenState extends State<StaffWorkSummaryScreen> {
  DateTime selectedDate = DateTime.now();
  Duration totalDuration = Duration.zero;
  List<Map<String, dynamic>> punches = [];

  Future<void> _fetchSummary() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.userId)
        .collection('logs')
        .doc(dateStr)
        .get();

    if (!doc.exists) {
      setState(() {
        punches = [];
        totalDuration = Duration.zero;
      });
      return;
    }

    final data = doc.data();
    final entries = List<Map<String, dynamic>>.from(data?['entries'] ?? []);
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
      totalDuration = total;
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
      _fetchSummary();
    }
  }

  String formatDuration(Duration d) => "${d.inHours}h ${d.inMinutes.remainder(60)}m";

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Daily Summary")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text("Date: "),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                ),
              ],
            ),
          ),
          Text("Total Hours: ${formatDuration(totalDuration)}",
              style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(
            child: punches.isEmpty
                ? const Center(child: Text("No punch data found"))
                : ListView.builder(
                    itemCount: punches.length,
                    itemBuilder: (context, index) {
                      final inTime = DateTime.parse(punches[index]['in']);
                      final outTime = punches[index]['out'] != null
                          ? DateTime.parse(punches[index]['out'])
                          : null;
                      final duration = outTime != null
                          ? outTime.difference(inTime)
                          : Duration.zero;

                      return ListTile(
                        title: Text("In: ${inTime.toLocal()}"),
                        subtitle: outTime != null
                            ? Text("Out: ${outTime.toLocal()}")
                            : const Text("Not yet punched out"),
                        trailing: outTime != null
                            ? Text(formatDuration(duration))
                            : null,
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
