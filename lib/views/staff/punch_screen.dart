import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PunchScreen extends StatefulWidget {
  final String userId;
  const PunchScreen({super.key, required this.userId});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  bool isPunchedIn = false;
  Timer? locationTimer;

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> _isNearOffice() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final officeId = userDoc.data()?['assignedOfficeId'];

    if (officeId == null) return false;

    final officeDoc = await FirebaseFirestore.instance.collection('offices').doc(officeId).get();
    final officeLat = officeDoc['lat'];
    final officeLng = officeDoc['lng'];

    final currentPos = await _getCurrentLocation();

    final distance = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      officeLat,
      officeLng,
    );

    return distance <= 1000; // within 1000 meters
  }

  Future<void> _punchIn() async {
    final allowed = await _isNearOffice();
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are not near the assigned office")),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.userId)
        .collection('logs')
        .doc(dateStr);

    final now = DateTime.now().toUtc().toIso8601String();

    final logSnap = await logRef.get();

    if (logSnap.exists) {
      await logRef.update({
        'entries': FieldValue.arrayUnion([{'in': now}]),
      });
    } else {
      await logRef.set({
        'entries': [{'in': now}],
      });
    }

    setState(() => isPunchedIn = true);
    _startTracking();
  }

  Future<void> _punchOut() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.userId)
        .collection('logs')
        .doc(dateStr);

    final now = DateTime.now().toUtc().toIso8601String();

    final logSnap = await logRef.get();
    if (!logSnap.exists) return;

    final entries = List<Map<String, dynamic>>.from(logSnap.data()?['entries'] ?? []);
    final last = entries.last;

    if (last['out'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already punched out")),
      );
      return;
    }

    last['out'] = now;
    entries[entries.length - 1] = last;

    await logRef.update({'entries': entries});

    setState(() => isPunchedIn = false);
    locationTimer?.cancel();
  }

  void _startTracking() {
    locationTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      final pos = await _getCurrentLocation();
      await FirebaseFirestore.instance
          .collection('location_logs')
          .doc(widget.userId)
          .collection('logs')
          .add({
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'lat': pos.latitude,
        'lng': pos.longitude,
      });
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Punch In/Out")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isPunchedIn
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    onPressed: _punchOut,
                    label: const Text("Punch Out"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  )
                : ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: _punchIn,
                    label: const Text("Punch In"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
          ],
        ),
      ),
    );
  }
}
