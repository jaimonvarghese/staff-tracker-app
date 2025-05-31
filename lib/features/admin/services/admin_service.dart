import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/office_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new office document
  Future<void> createOffice(Office office) async {
    await _db.collection('offices').add(office.toMap());
  }

  /// Fetch list of all offices
  Future<List<Office>> fetchOffices() async {
    final snapshot = await _db.collection('offices').get();
    return snapshot.docs.map((doc) => Office.fromMap(doc.id, doc.data())).toList();
  }

  /// Assign a staff user to an office and log the assignment
  Future<void> assignStaffToOffice(String userId, String officeId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final officeDoc = await _db.collection('offices').doc(officeId).get();

    if (!userDoc.exists) throw Exception("User not found");
    if (!officeDoc.exists) throw Exception("Office not found");

    final userName = userDoc['name'];
    final officeName = officeDoc['name'];

    // Update user's assigned office
    await _db.collection('users').doc(userId).update({
      'assignedOfficeId': officeId,
    });

    // Log the assignment in 'assignment_logs' collection
    await _db.collection('assignment_logs').add({
      'userId': userId,
      'userName': userName,
      'officeId': officeId,
      'officeName': officeName,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all staff users (role == staff)
  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final snap = await _db.collection('users').where('role', isEqualTo: 'staff').get();
    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get the latest live location of a staff member
  Future<LatLng?> getLatestLocation(String staffId) async {
    final snapshot = await _db
        .collection('location_logs')
        .doc(staffId)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    if (data.containsKey('lat') && data.containsKey('lng')) {
      return LatLng(data['lat'], data['lng']);
    }

    return null;
  }



  //Working hours report
  

Future<Map<String, dynamic>> getDailyWorkingSummary(String userId, DateTime date) async {
  final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  final doc = await FirebaseFirestore.instance
      .collection('attendance')
      .doc(userId)
      .collection('logs')
      .doc(dateStr)
      .get();

  if (!doc.exists) {
    return {
      'entries': [],
      'total': Duration.zero,
    };
  }

  final entries = List<Map<String, dynamic>>.from(doc['entries']);
  Duration total = Duration.zero;

  for (var entry in entries) {
    if (entry['in'] != null && entry['out'] != null) {
      final inTime = DateTime.parse(entry['in']);
      final outTime = DateTime.parse(entry['out']);
      total += outTime.difference(inTime);
    }
  }

  return {
    'entries': entries,
    'total': total,
  };
}

}
