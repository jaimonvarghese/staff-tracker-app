import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:staff_tracking_app/views/admin/admin_home.dart';

class CreateOfficeScreen extends StatefulWidget {
  const CreateOfficeScreen({Key? key}) : super(key: key);

  @override
  State<CreateOfficeScreen> createState() => _CreateOfficeScreenState();
}

class _CreateOfficeScreenState extends State<CreateOfficeScreen> {
  LatLng? selectedLocation;
  LatLng? currentLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();
    setState(() {
      currentLocation = LatLng(loc.latitude!, loc.longitude!);
      selectedLocation ??= currentLocation;
      _mapController.move(currentLocation!, 15.0);
    });
  }

  Future<void> _searchCity(String city) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1');
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final lat = double.parse(data[0]['lat']);
      final lon = double.parse(data[0]['lon']);
      final LatLng found = LatLng(lat, lon);
      setState(() {
        selectedLocation = found;
        _mapController.move(found, 15.0);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City not found")),
      );
    }
  }

  Future<void> _saveOffice() async {
  if (selectedLocation == null || _nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a location and enter a name")),
    );
    return;
  }

  try {
    print("Trying to save office: ${_nameController.text} at $selectedLocation");

    await FirebaseFirestore.instance.collection('offices').add({
      'name': _nameController.text.trim(),
      'lat': selectedLocation!.latitude,
      'lng': selectedLocation!.longitude,
    });

    print("Office saved successfully");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Office saved successfully")),
    );

    _nameController.clear();
    setState(() => selectedLocation = null);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminHome()),
    );
  } catch (e, stack) {
    print("Failed to save: $e\n$stack");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Office Location")),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchCity(_searchController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          /// Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation ?? const LatLng(9.44, 76.40),
                interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                initialZoom: 15.0,
                onTap: (_, latLng) {
                  setState(() => selectedLocation = latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                if (selectedLocation != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ]),
                if (currentLocation != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: currentLocation!,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ]),
              ],
            ),
          ),

          /// Office Name & Save
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Office Name"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveOffice,
                  child: const Text("Save Office"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
