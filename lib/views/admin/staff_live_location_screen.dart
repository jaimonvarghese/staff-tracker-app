import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StaffLiveLocationScreen extends StatefulWidget {
  const StaffLiveLocationScreen({Key? key}) : super(key: key);

  @override
  State<StaffLiveLocationScreen> createState() =>
      _StaffLiveLocationScreenState();
}

class _StaffLiveLocationScreenState extends State<StaffLiveLocationScreen> {
  String? selectedStaffId;
  LatLng? latestLocation;

  Future<List<QueryDocumentSnapshot>> _getStaffList() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'staff')
            .get();
    return snapshot.docs;
  }

  Future<void> _fetchLatestLocation(String staffId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('location_logs')
            .doc(staffId)
            .collection('logs')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        latestLocation = LatLng(data['lat'], data['lng']);
        selectedStaffId = staffId;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location found for this staff')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Live Location')),
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
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) _fetchLatestLocation(val);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                latestLocation != null
                    ? FlutterMap(
                      options: MapOptions(
                        initialCenter: latestLocation!,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: latestLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : const Center(
                      child: Text('Select a staff to view location'),
                    ),
          ),
        ],
      ),
    );
  }
}
