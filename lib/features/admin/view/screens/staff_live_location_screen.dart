import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../admin/providers/admin_provider.dart';

class StaffLiveLocationScreen extends ConsumerStatefulWidget {
  const StaffLiveLocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffLiveLocationScreen> createState() =>
      _StaffLiveLocationScreenState();
}

class _StaffLiveLocationScreenState
    extends ConsumerState<StaffLiveLocationScreen> {
  String? selectedStaffId;
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> staffList = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final result = await ref.read(adminViewModelProvider).getAllStaff();
    setState(() {
      staffList = result;
    });
  }

  Future<void> _onStaffSelected(String staffId) async {
    selectedStaffId = staffId;
    await ref.read(adminViewModelProvider).loadLatestLocation(staffId);

    final latest = ref.read(adminViewModelProvider).latestLocation;
    if (latest != null) {
      _mapController.move(latest, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No location found for this staff")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = ref.watch(adminViewModelProvider);
    final LatLng defaultCenter = const LatLng(10.0, 76.0);
    final latestLocation = adminVM.latestLocation;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Staff Live Location"),
        backgroundColor: Colors.black,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
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
                  staffList.map<DropdownMenuItem<String>>((staff) {
                    return DropdownMenuItem<String>(
                      value: staff['id'] as String,
                      child: Text(
                        staff['name'] ?? 'Unnamed',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }).toList(),

              onChanged: (val) {
                if (val != null) _onStaffSelected(val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: latestLocation ?? defaultCenter,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (latestLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latestLocation,
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
              ),
            ),
            if (latestLocation == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Select a staff to view their current location.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
