
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/features/staff/viewmodels/staff_view_model.dart';
import '../services/staff_service.dart';

final staffServiceProvider = Provider((ref) => StaffService());

final staffViewModelProvider = ChangeNotifierProvider(
  (ref) => StaffViewModel(ref.watch(staffServiceProvider)),
);

// final punchHistoryProvider =
//     StreamProvider.family<QuerySnapshot, String>((ref, userId) {
//   final service = ref.read(staffServiceProvider);
//   return service.getUserLogs(userId);
// });
