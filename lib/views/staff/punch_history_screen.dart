import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PunchHistoryScreen extends StatelessWidget {
  final String userId;
  const PunchHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final logsRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(userId)
        .collection('logs')
        .orderBy(FieldPath.documentId, descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Punch History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: logsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final logs = snapshot.data!.docs;

          if (logs.isEmpty) {
            return const Center(child: Text("No punch history found"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final doc = logs[index];
              final date = doc.id;
              final entries = List<Map<String, dynamic>>.from(doc['entries']);

              return ExpansionTile(
                title: Text("Date: $date"),
                children: entries.map((entry) {
                  final inTime = DateTime.parse(entry['in']).toLocal();
                  final outTime = entry['out'] != null
                      ? DateTime.parse(entry['out']).toLocal()
                      : null;
                  final duration = outTime != null ? outTime.difference(inTime) : null;

                  return ListTile(
                    title: Text("In: ${DateFormat.Hm().format(inTime)}"),
                    subtitle: outTime != null
                        ? Text("Out: ${DateFormat.Hm().format(outTime)}")
                        : const Text("Still active"),
                    trailing: duration != null
                        ? Text("${duration.inHours}h ${duration.inMinutes % 60}m")
                        : null,
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
