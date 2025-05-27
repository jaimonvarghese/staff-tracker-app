import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class SyncService {
  Future<void> syncData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final punchBox = Hive.box('offline_punches');
    final locationBox = Hive.box('offline_locations');

    for (int i = 0; i < punchBox.length; i++) {
      final punch = punchBox.getAt(i);
      try {
        final docRef = FirebaseFirestore.instance
            .collection('attendance')
            .doc(punch['userId'])
            .collection('logs')
            .doc(punch['date']);

        final field = punch['type'] == 'in' ? {'in': punch['timestamp']} : {'out': punch['timestamp']};

        await docRef.set({
          'entries': FieldValue.arrayUnion([field])
        }, SetOptions(merge: true));

        punchBox.deleteAt(i);
        i--;
      } catch (_) {}
    }

    for (int i = 0; i < locationBox.length; i++) {
      final log = locationBox.getAt(i);
      try {
        await FirebaseFirestore.instance
            .collection('location_logs')
            .doc(log['userId'])
            .collection('logs')
            .add({
          'lat': log['lat'],
          'lng': log['lng'],
          'timestamp': log['timestamp'],
        });

        locationBox.deleteAt(i);
        i--;
      } catch (_) {}
    }
  }
}
