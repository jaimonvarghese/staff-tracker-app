import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class WorkingHoursReportScreen extends StatefulWidget {
  const WorkingHoursReportScreen({super.key});

  @override
  State<WorkingHoursReportScreen> createState() =>
      _WorkingHoursReportScreenState();
}

class _WorkingHoursReportScreenState extends State<WorkingHoursReportScreen> {
  String? selectedStaffId;
  DateTime selectedDate = DateTime.now();
  Duration totalHours = Duration.zero;
  List<Map<String, dynamic>> punches = [];

  Future<List<QueryDocumentSnapshot>> _getStaffList() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'staff')
            .get();
    return snapshot.docs;
  }

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

    if (doc.exists) {
      final data = doc.data()!;
      final entries = List<Map<String, dynamic>>.from(data['entries']);
      punches = entries;

      Duration total = Duration.zero;
      for (var entry in entries) {
        if (entry['in'] != null && entry['out'] != null) {
          final inTime = DateTime.parse(entry['in']);
          final outTime = DateTime.parse(entry['out']);
          total += outTime.difference(inTime);
        }
      }

      setState(() => totalHours = total);
    } else {
      setState(() {
        totalHours = Duration.zero;
        punches = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No punch data for selected date')),
      );
    }
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

  String formatDuration(Duration duration) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Working Hours Summary")),
      body: Column(
        children: [
          FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _getStaffList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final staffList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<String>(
                  hint: const Text("Select Staff"),
                  value: selectedStaffId,
                  items:
                      staffList.map((doc) {
                        final name =
                            doc.data().toString().contains('name')
                                ? doc['name']
                                : 'Unnamed';
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(name ?? 'Unnamed'),
                        );
                      }).toList(),
                  onChanged: (val) async {
                    setState(() => selectedStaffId = val);
                    await _fetchWorkingHours();
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text("Date: "),
                TextButton(
                  onPressed: _pickDate,
                  child: Text("${selectedDate.toLocal()}".split(" ")[0]),
                ),
              ],
            ),
          ),
          const Divider(),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Export to PDF"),
            onPressed: punches.isEmpty ? null : _generatePdf,
          ),

          Text(
            "Total Working Time: ${formatDuration(totalHours)}",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text("Punch Entries:"),
          Expanded(
            child: ListView.builder(
              itemCount: punches.length,
              itemBuilder: (context, index) {
                final entry = punches[index];
                final inTime = DateTime.parse(entry['in']);
                final outTime = DateTime.parse(entry['out']);
                final duration = outTime.difference(inTime);
                return ListTile(
                  title: Text("In: ${inTime.toLocal()}"),
                  subtitle: Text("Out: ${outTime.toLocal()}"),
                  trailing: Text(formatDuration(duration)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Working Hours Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("Staff ID: $selectedStaffId"),
                pw.Text("Date: ${selectedDate.toLocal()}".split(" ")[0]),
                pw.SizedBox(height: 10),
                pw.Text("Total Duration: ${formatDuration(totalHours)}"),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Punch Entries:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                ...punches.map((entry) {
                  final inTime = DateTime.parse(entry['in']);
                  final outTime = DateTime.parse(entry['out']);
                  final duration = outTime.difference(inTime);
                  return pw.Text(
                    "- In: ${inTime.toLocal()}, Out: ${outTime.toLocal()} (${formatDuration(duration)})",
                  );
                }).toList(),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
