import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/staff_service.dart';

class StaffViewModel extends ChangeNotifier {
  final StaffService staffService;
  bool isPunchedIn = false;
  Timer? _locationTimer;

  StaffViewModel(this.staffService);
  DateTime selectedDate = DateTime.now();
  Duration totalDuration = Duration.zero;
  List<Map<String, dynamic>> punches = [];

  Future<String?> punchIn(String userId) async {
    final isNear = await staffService.isNearAssignedOffice(userId);
    if (!isNear) {
      return "You are not near the assigned office.";
    }

    await staffService.punchIn(userId);
    isPunchedIn = true;
    notifyListeners();
    _startLocationTracking(userId);
    return null;
  }

  Future<String?> punchOut(String userId) async {
    await staffService.punchOut(userId);
    isPunchedIn = false;
    notifyListeners();
    _locationTimer?.cancel();
    return null;
  }

  void _startLocationTracking(String userId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      staffService.logLocation(userId);
    });
  }

  Future<void> fetchSummary(String userId) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final entries = await staffService.fetchPunches(userId, dateStr);

    Duration total = Duration.zero;
    for (var entry in entries) {
      if (entry['in'] != null && entry['out'] != null) {
        final inTime = DateTime.parse(entry['in']);
        final outTime = DateTime.parse(entry['out']);
        total += outTime.difference(inTime);
      }
    }

    punches = entries;
    totalDuration = total;
    notifyListeners();
  }

  void updateDate(DateTime newDate, String userId) {
    selectedDate = newDate;
    fetchSummary(userId);
  }

  Stream<QuerySnapshot> getPunchHistoryStream(String userId) {
    return staffService.getUserLogs(userId);
  }

  List<Map<String, dynamic>> parseEntries(dynamic entriesData) {
    if (entriesData is List) {
      return List<Map<String, dynamic>>.from(entriesData);
    }
    return [];
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
