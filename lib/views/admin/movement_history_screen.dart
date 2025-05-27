import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({super.key});

  @override
  State<MovementHistoryScreen> createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  String? selectedStaffId;
  DateTime selectedDate = DateTime.now();
  List<LatLng> pathPoints = [];

  Future<List<QueryDocumentSnapshot>> _getStaffList() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .get();
    return snapshot.docs;
  }

  Future<void> _fetchPath() async {
    if (selectedStaffId == null) return;

    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await FirebaseFirestore.instance
        .collection('location_logs')
        .doc(selectedStaffId)
        .collection('logs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .orderBy('timestamp')
        .get();

    setState(() {
      pathPoints = query.docs.map((doc) {
        final data = doc.data();
        return LatLng(data['lat'], data['lng']);
      }).toList();
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
      await _fetchPath();
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = pathPoints.isNotEmpty ? pathPoints.first : LatLng(10.0, 76.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Movement History')),
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
                  items: staffList.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    setState(() => selectedStaffId = val);
                    await _fetchPath();
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
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                if (pathPoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: pathPoints,
                        color: Colors.blue,
                        strokeWidth: 5,
                      )
                    ],
                  ),
                if (pathPoints.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pathPoints.first,
                        width: 40,
                        height: 40,
                        child:  Icon(Icons.location_pin, color: Colors.green),
                      ),
                      Marker(
                        point: pathPoints.last,
                        width: 40,
                        height: 40,
                        child:  Icon(Icons.flag, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
