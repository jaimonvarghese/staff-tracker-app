import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import '../viewmodels/admin_viewmodel.dart';

final adminServiceProvider = Provider((ref) => AdminService());

final adminViewModelProvider = ChangeNotifierProvider(
  (ref) => AdminViewModel(ref.watch(adminServiceProvider)),
);
