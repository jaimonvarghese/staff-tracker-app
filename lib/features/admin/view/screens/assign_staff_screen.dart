import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../admin/providers/admin_provider.dart';

class AssignStaffScreen extends ConsumerStatefulWidget {
  const AssignStaffScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AssignStaffScreen> createState() => _AssignStaffScreenState();
}

class _AssignStaffScreenState extends ConsumerState<AssignStaffScreen> {
  String? selectedOfficeId;
  List<Map<String, dynamic>> staffList = [];
  Map<String, String> officeMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vm = ref.read(adminViewModelProvider);
    await vm.loadOffices();
    final staff = await vm.getAllStaff();

    setState(() {
      staffList = staff;
      officeMap = {for (var office in vm.offices) office.id: office.name};
    });
  }

  void _assignOffice(String userId) async {
    if (selectedOfficeId == null) {
      _showMsg("Please select an office");
      return;
    }

    await ref
        .read(adminViewModelProvider)
        .assignStaffToOffice(userId, selectedOfficeId!);
    _showMsg("Assigned successfully");

    // Refresh to update current office
    await _loadData();
  }

  void _showMsg(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(adminViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Assign Staff to Office"),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body:
          vm.isLoading && officeMap.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF2C2C2C),
                      value: selectedOfficeId,
                      hint: Text(
                        'Select Office',
                        style: TextStyle(color: Colors.white54),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          officeMap.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => selectedOfficeId = val),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Expanded(
                      child:
                          staffList.isEmpty
                              ? const Center(
                                child: Text(
                                  "No staff available",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              : ListView.separated(
                                itemCount: staffList.length,
                                separatorBuilder:
                                    (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final staff = staffList[index];
                                  final name = staff['name'] ?? 'Unnamed';
                                  final assignedOfficeId =
                                      staff['assignedOfficeId'];
                                  final assignedOffice =
                                      assignedOfficeId != null
                                          ? officeMap[assignedOfficeId] ??
                                              'Unknown'
                                          : 'Not Assigned';

                                  return ListTile(
                                    title: Text(
                                      name,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "Current Office: $assignedOffice",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed:
                                          () => _assignOffice(staff['id']),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFEB2F3D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Assign",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
