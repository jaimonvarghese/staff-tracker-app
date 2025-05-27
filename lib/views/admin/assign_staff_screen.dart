import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignStaffScreen extends StatefulWidget {
  const AssignStaffScreen({Key? key}) : super(key: key);

  @override
  State<AssignStaffScreen> createState() => _AssignStaffScreenState();
}

class _AssignStaffScreenState extends State<AssignStaffScreen> {
  String? selectedOfficeId;

  Future<void> assignOffice(String userId) async {
    if (selectedOfficeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an office")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'assignedOfficeId': selectedOfficeId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assigned successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final officesRef = FirebaseFirestore.instance.collection('offices');
    final staffRef = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'staff');

    return Scaffold(
      appBar: AppBar(title: const Text("Assign Staff to Office")),
      body: Column(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: officesRef.get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final offices = snapshot.data!.docs;

              return DropdownButtonFormField<String>(
                hint: const Text("Select Office"),
                value: selectedOfficeId,
                items: offices.map((doc) {
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedOfficeId = val;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: staffRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final staffDocs = snapshot.data!.docs;

                if (staffDocs.isEmpty) {
                  return const Center(child: Text("No staff found"));
                }

                return ListView.builder(
                  itemCount: staffDocs.length,
                  itemBuilder: (context, index) {
                    final staff = staffDocs[index];
                    final currentOffice = staff['assignedOfficeId'] ?? 'Not Assigned';

                    return ListTile(
                      title: Text(staff['name']),
                      subtitle: Text("Current Office: $currentOffice"),
                      trailing: ElevatedButton(
                        onPressed: () => assignOffice(staff.id),
                        child: const Text("Assign"),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
