import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/office_model.dart';
import '../services/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService;

  AdminViewModel(this._adminService);

  List<Office> offices = [];
  bool isLoading = false;

  Duration totalWorkDuration = Duration.zero;
  List<Map<String, dynamic>> punchEntries = [];

  LatLng? latestLocation;
  List<LatLng> movementPath = [];

  /// Load all offices
  Future<void> loadOffices() async {
    _setLoading(true);
    try {
      offices = await _adminService.fetchOffices();
    } catch (e) {
      offices = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new office and refresh office list
  Future<void> createNewOffice(String name, double lat, double lng) async {
    final newOffice = Office(id: '', name: name, lat: lat, lng: lng);
    await _adminService.createOffice(newOffice);
    await loadOffices(); // Refresh after creation
  }

  /// Assign a staff member to an office
  Future<void> assignStaffToOffice(String userId, String officeId) async {
    await _adminService.assignStaffToOffice(userId, officeId);
  }

  /// Fetch all staff users with role 'staff'
  Future<List<Map<String, dynamic>>> getAllStaff() async {
    return await _adminService.getAllStaff();
  }

  /// Load the latest live location of a staff user
  Future<void> loadLatestLocation(String staffId) async {
    latestLocation = await _adminService.getLatestLocation(staffId);
    notifyListeners();
  }



  /// Load working summary (punch in/out entries and total duration) for a date
  Future<void> loadDailySummary(String userId, DateTime date) async {
    final summary = await _adminService.getDailyWorkingSummary(userId, date);
    punchEntries = summary['entries'];
    totalWorkDuration = summary['total'];
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
