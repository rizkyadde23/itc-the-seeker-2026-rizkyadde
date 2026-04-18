import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/models/member_model.dart';
import 'package:seeker/routes/app_routes.dart';
import 'package:seeker/services/firestore_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // 🔥 GET STATS
  Future<Map<String, int>> getStats() async {
    try {
      print("START GET STATS");

      final members = await FirebaseFirestore.instance
          .collection('members')
          .get();

      final users = await FirebaseFirestore.instance.collection('users').get();

      final divisions = await FirebaseFirestore.instance
          .collection('divisions')
          .get();

      int adminCount = users.docs.where((e) => e['role'] == 'admin').length;

      print("SUCCESS GET STATS");

      return {
        'members': members.docs.length,
        'admins': adminCount,
        'divisions': divisions.docs.length,
      };
    } catch (e) {
      print("ERROR GET STATS: $e");
      rethrow;
    }
  }

  // 🔥 STAT CARD
  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 OVERVIEW
  Widget buildOverview(Map<String, int> stats) {
    return Row(
      children: [
        _statCard("Members", stats['members'].toString(), Icons.people),
        const SizedBox(width: 10),
        _statCard(
          "Admins",
          stats['admins'].toString(),
          Icons.admin_panel_settings,
        ),
        const SizedBox(width: 10),
        _statCard(
          "Divisions",
          stats['divisions'].toString(),
          Icons.account_tree,
        ),
      ],
    );
  }

  // 🔥 QUICK ACTION
  Widget buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(AppRoutes.addDivision);
          },
          icon: const Icon(Icons.apartment),
          label: const Text("Add Division"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(AppRoutes.inactive);
          },
          icon: const Icon(Icons.person_2),
          label: const Text("Inactive Member"),
        ),
      ],
    );
  }

  // 🔥 DELETE CONFIRM
  void showDeactivateMemberDialog(Member member) {
    Get.defaultDialog(
      title: "Nonaktifkan Member",
      middleText: "Yakin ingin menonaktifkan member ini?",
      textConfirm: "Nonaktifkan",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await FirebaseFirestore.instance
            .collection('members')
            .doc(member.id)
            .update({'status': 'Inactive'});

        setState(() {
          Get.back();
        });
        Get.snackbar("Success", "Member dinonaktifkan");
      },
    );
  }

  void showDeleteDivisionDialog(QueryDocumentSnapshot division) {
    Get.defaultDialog(
      title: "Hapus Divisi",
      middleText: "Semua anggota akan keluar dari divisi ini. Yakin?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await FirestoreService().deleteDivision(division.id);
        setState(() {
          Get.back();
        });
        Get.snackbar("Success", "Divisi berhasil dihapus");
      },
    );
  }

  Widget buildDivisionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('divisions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final divisions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Divisions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ...divisions.map((d) {
              return ListTile(
                leading: Icon(Icons.apartment),
                title: Text(d['name']),
                subtitle: Text(
                  d['leaderId'] != "" ? "Leader assigned" : "Belum ada ketua",
                ),

                // 🔥 ACTION BUTTONS
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          Get.toNamed(AppRoutes.editDivison, arguments: d),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showDeleteDivisionDialog(d),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // 🔥 MEMBER LIST (REALTIME)
  Widget buildMemberList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('status', isEqualTo: 'Active')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada member"));
        }

        final members = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final doc = members[index];
            final member = Member.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(child: const Icon(Icons.person)),
                title: Text(doc['name'] ?? '-'),
                subtitle: Text(doc['role'] ?? '-'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 EDIT
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Get.toNamed('/profile', arguments: doc.id);
                      },
                    ),

                    // 🔥 DELETE
                    IconButton(
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDeactivateMemberDialog(member);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 OVERVIEW
            FutureBuilder<Map<String, int>>(
              future: getStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData) {
                  return Text("No data");
                }

                return buildOverview(snapshot.data!);
              },
            ),

            const SizedBox(height: 20),

            // 🔥 QUICK ACTION
            buildQuickActions(),

            const SizedBox(height: 20),

            // 🔥 TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Member Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            buildDivisionList(),

            const SizedBox(height: 10),
            // 🔥 MEMBER LIST
            buildMemberList(),
          ],
        ),
      ),
    );
  }
}
