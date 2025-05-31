import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class StaffService {
  static const double allowedDistance = 100; // in meters
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> isNearAssignedOffice(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final officeId = userDoc.data()?['assignedOfficeId'];
    if (officeId == null) return false;

    final officeDoc = await FirebaseFirestore.instance
        .collection('offices')
        .doc(officeId)
        .get();

    final officeLat = officeDoc['lat'];
    final officeLng = officeDoc['lng'];
    final currentPos = await getCurrentLocation();

    final distance = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      officeLat,
      officeLng,
    );

    return distance <= allowedDistance;
  }

  Future<void> punchIn(String userId) async {
    final now = DateTime.now().toUtc();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final logRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(userId)
        .collection('logs')
        .doc(dateStr);

    final logSnap = await logRef.get();

    if (logSnap.exists) {
      await logRef.update({
        'entries': FieldValue.arrayUnion([{'in': now.toIso8601String()}])
      });
    } else {
      await logRef.set({
        'entries': [{'in': now.toIso8601String()}]
      });
    }
  }

  Future<void> punchOut(String userId) async {
    final now = DateTime.now().toUtc();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final logRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(userId)
        .collection('logs')
        .doc(dateStr);

    final logSnap = await logRef.get();
    if (!logSnap.exists) return;

    final entries = List<Map<String, dynamic>>.from(logSnap.data()?['entries'] ?? []);
    if (entries.isEmpty || entries.last['out'] != null) return;

    entries[entries.length - 1]['out'] = now.toIso8601String();
    await logRef.update({'entries': entries});
  }

  Future<void> logLocation(String userId) async {
    final position = await getCurrentLocation();
    await FirebaseFirestore.instance
        .collection('location_logs')
        .doc(userId)
        .collection('logs')
        .add({
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'lat': position.latitude,
      'lng': position.longitude,
    });
  }

   Future<List<Map<String, dynamic>>> fetchPunches(String userId, String dateStr) async {
    final logDoc = await _firestore
        .collection('attendance')
        .doc(userId)
        .collection('logs')
        .doc(dateStr)
        .get();

    if (!logDoc.exists) return [];

    final data = logDoc.data();
    return List<Map<String, dynamic>>.from(data?['entries'] ?? []);
  }

     Stream<QuerySnapshot> getUserLogs(String userId) {
    return _firestore
        .collection('attendance')
        .doc(userId)
        .collection('logs')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();
  }
}
