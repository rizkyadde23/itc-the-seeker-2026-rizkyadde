import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // 🔥 GET STATS
  Future<Map<String, int>> getStats() async {
    final members = await FirebaseFirestore.instance
        .collection('members')
        .get();

    final users = await FirebaseFirestore.instance.collection('users').get();
    final division = await FirebaseFirestore.instance.collection('division').get();

    int adminCount = users.docs.where((e) => e['role'] == 'admin').length;

    return {
      'members': members.docs.length,
      'admins': adminCount,
      'divisions': division.docs.length, // nanti bisa kamu isi
    };
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
      ],
    );
  }

  // 🔥 DELETE CONFIRM
  void showDeleteDialog(String id) {
    Get.defaultDialog(
      title: "Hapus Member",
      middleText: "Yakin ingin menghapus member ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await FirebaseFirestore.instance.collection('members').doc(id).delete();
        await FirebaseFirestore.instance.collection('users').doc(id).delete();
        Get.back(); // tutup dialog
        Get.snackbar("Success", "Member dihapus");
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
                  d['leaderId'] != null ? "Leader assigned" : "Belum ada ketua",
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // 🔥 MEMBER LIST (REALTIME)
  Widget buildMemberList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('members').snapshots(),
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
            final data = members[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(child: const Icon(Icons.person)),
                title: Text(data['name'] ?? '-'),
                subtitle: Text(data['role'] ?? '-'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 EDIT
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Get.toNamed('/profile', arguments: data.id);
                      },
                    ),

                    // 🔥 DELETE
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDeleteDialog(data.id);
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
            FutureBuilder(
              future: getStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
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
