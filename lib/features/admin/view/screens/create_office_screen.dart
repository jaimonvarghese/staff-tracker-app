import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:staff_tracking_app/common/widgets/custom_textfield.dart';
import 'package:staff_tracking_app/features/admin/providers/admin_provider.dart';
import 'admin_home.dart';

class CreateOfficeScreen extends ConsumerStatefulWidget {
  const CreateOfficeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateOfficeScreen> createState() => _CreateOfficeScreenState();
}

class _CreateOfficeScreenState extends ConsumerState<CreateOfficeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? selectedLocation;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final location = Location();

    if (!await location.serviceEnabled() && !await location.requestService())
      return;

    final permission = await location.hasPermission();
    if (permission == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted)
      return;

    final loc = await location.getLocation();
    final position = LatLng(loc.latitude!, loc.longitude!);

    setState(() {
      currentLocation = position;
      selectedLocation ??= position;
    });

    _mapController.move(position, 15.0);
  }

  Future<void> _searchCity(String city) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1',
    );
    final response = await http.get(url);

    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final found = LatLng(
        double.parse(data[0]['lat']),
        double.parse(data[0]['lon']),
      );
      setState(() => selectedLocation = found);
      _mapController.move(found, 15.0);
    } else {
      _showMessage("City not found");
    }
  }

  Future<void> _saveOffice() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || selectedLocation == null) {
      _showMessage("Please enter an office name and select a location");
      return;
    }

    try {
      await ref
          .read(adminViewModelProvider)
          .createNewOffice(
            name,
            selectedLocation!.latitude,
            selectedLocation!.longitude,
          );

      _showMessage("Office saved successfully");

      _nameController.clear();
      setState(() => selectedLocation = null);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } catch (e) {
      _showMessage("Failed to save: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = ref.watch(adminViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Office Location"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            
            child: CustomTextfield(
              controller: _searchController,
              hint: 'Search City',
              onValidator: (value) {},
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _searchCity(_searchController.text),
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLocation ?? const LatLng(10.0, 76.0),
                    initialZoom: 15.0,
                    onTap:
                        (_, latLng) =>
                            setState(() => selectedLocation = latLng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation!,
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 📍 Current Location Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          await _fetchCurrentLocation();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📝 Input + Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextfield(
                  controller: _nameController,
                  hint: 'Office Name',
                  onValidator: (value) {},
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C2C2C),
                    foregroundColor: Colors.white
                  ),
                  icon: const Icon(Icons.save,color: Colors.white,),
                  label:
                      adminVM.isLoading
                          ? const Text("Saving...")
                          : const Text("Save Office"),
                  onPressed: adminVM.isLoading ? null : _saveOffice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
