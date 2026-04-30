import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FirestoreService service = FirestoreService();
  Future<Map<String, int>> getStats() async {
    try {
      await FirestoreService().syncOrganizationRoles();
      final members = await FirebaseFirestore.instance
          .collection('members')
          .get();

      final users = await FirebaseFirestore.instance.collection('users').get();

      final divisions = await FirebaseFirestore.instance
          .collection('divisions')
          .get();

      int adminCount = users.docs.where((e) => e['role'] == 'admin').length;

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
        color: Colors.greenAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Colors.black,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialButton(
            onPressed: () {
              Get.toNamed(AppRoutes.editOrganization);
            },
            color: Colors.lightGreen,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.group, color: Colors.white),
                Text(
                  "Edit Organization",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          MaterialButton(
            onPressed: () {
              Get.toNamed(AppRoutes.addDivision);
            },
            color: const Color.fromARGB(255, 25, 107, 23),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.apartment, color: Colors.white),
                Text(
                  "Add Division",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          MaterialButton(
            onPressed: () {
              Get.toNamed(AppRoutes.inactive);
            },
            color: const Color.fromARGB(255, 16, 188, 13),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white),
                Text(
                  "Inactive Member",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 DELETE CONFIRM
  void showDeactivateMemberDialog(Member member) {
    Get.defaultDialog(
      title: "Nonaktifkan Member?",
      middleText: "Apakah Kamu Yakin?",
      buttonColor: Colors.red,
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 255, 0, 0),
        onPressed: () async {
          await FirestoreService().deactivateMember(member);
          setState(() {
            Get.back();
          });
          Get.snackbar("Success", "Member dinonaktifkan");
        },
        child: Text("Nonaktifkan", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void showDeleteDivisionDialog(QueryDocumentSnapshot division) {
    Get.defaultDialog(
      title: "Delete Divisi",
      middleText: "Apakah Kamu Yakin?",
      buttonColor: Colors.red,
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 255, 0, 0),
        onPressed: () async {
          await FirestoreService().deleteDivision(division.id);
          setState(() {
            Get.back();
          });
          Get.snackbar("Success", "Divisi berhasil dihapus");
        },
        child: Text("Delete", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void showSignOutDialog() {
    Get.defaultDialog(
      title: "Sign Out",
      middleText: "Apakah Kamu Yakin?",
      buttonColor: Colors.red,
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 255, 0, 0),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.login);
            Get.snackbar("Signing Out", "Anda Telah Keluar");
          } catch (e) {
            Get.snackbar("Error", e.toString());
          }
        },
        child: Text("Sign Out", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget buildDivisionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getDivisions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada divisi"));
        }

        final divisions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...divisions.map((d) {
              return Card(
                elevation: 5,
                shadowColor: Colors.black,
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.apartment),
                  title: Text(d['name']),
                  subtitle: Text(
                    d['headId'] != "" ? "Leader assigned" : "Belum ada ketua",
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
              color: Colors.white,
              shadowColor: Colors.black,
              elevation: 5,
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

                    //Nonactive
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

  Widget buildOrganizationControl() {
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('organization')
              .doc('main')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final leaderId = data['leaderId'] ?? '';
            final viceLeaderId = data['viceLeaderId'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Organization Leadership",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                // 🔥 KETUA UMUM
                _buildLeaderTile(
                  title: "Ketua Umum",
                  memberId: leaderId,
                  onAssign: () => showAssignDialog(isLeader: true),
                  onRemove: leaderId != ''
                      ? () {
                          showDeleteLeaderDialog();
                        }
                      : null,
                ),

                const SizedBox(height: 10),

                // 🔥 WAKIL
                _buildLeaderTile(
                  title: "Wakil Ketua Umum",
                  memberId: viceLeaderId,
                  onAssign: () => showAssignDialog(isLeader: false),
                  onRemove: viceLeaderId != ''
                      ? () {
                          showDeleteViceLeaderDialog();
                        }
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<dynamic> showDeleteLeaderDialog() {
    return Get.defaultDialog(
      title: "Hapus Leader",
      middleText: "Apakah Kamu Yakin?",
      buttonColor: Colors.red,
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 255, 0, 0),
        onPressed: () async {
          try {
            await service.removeGeneralLeader();
            Get.back();
            Get.snackbar("Success", "Ketua Umum dihapus");
          } catch (e) {
            Get.snackbar("Error", e.toString());
          }
        },
        child: Text("Hapus", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Future<dynamic> showDeleteViceLeaderDialog() {
    return Get.defaultDialog(
      title: "Hapus Leader",
      middleText: "Apakah Kamu Yakin?",
      buttonColor: Colors.red,
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 255, 0, 0),
        onPressed: () async {
          try {
            await service.removeGeneralViceLeader();
            Get.back();
            Get.snackbar("Success", "Wakil Ketua Umum dihapus");
          } catch (e) {
            Get.snackbar("Error", e.toString());
          }
        },
        child: Text("Hapus", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildLeaderTile({
    required String title,
    required String memberId,
    required VoidCallback onAssign,
    VoidCallback? onRemove,
  }) {
    if (memberId == '') {
      return ListTile(
        leading: const Icon(Icons.star),
        title: Text(title),
        subtitle: const Text("Belum ada"),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onAssign),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .doc(memberId)
          .snapshots(),
      builder: (context, snapshot) {
        String name = "Belum ada";

        if (snapshot.hasData && snapshot.data!.exists) {
          name = snapshot.data!['name'];
        }

        return ListTile(
          leading: const Icon(Icons.star),
          title: Text(title),
          subtitle: Text(name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: onAssign),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
            ],
          ),
        );
      },
    );
  }

  void showAssignDialog({required bool isLeader}) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Text(
                isLeader ? "Pilih Ketua Umum" : "Pilih Wakil Ketua",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final members = snapshot.data!.docs;

                    return ListView(
                      children: members.map((m) {
                        return ListTile(
                          title: Text(m['name']),
                          subtitle: Text(m['role']),
                          onTap: () {
                            showAssignLeaderDialog(isLeader: isLeader, m: m);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAssignLeaderDialog({
    required bool isLeader,
    required QueryDocumentSnapshot m,
  }) {
    Get.defaultDialog(
      title: "Assign Leader",
      middleText: "Apakah Kamu Yakin?",
      cancel: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.black)),
      ),
      confirm: MaterialButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 64, 255, 0),
        onPressed: () async {
          if (isLeader) {
            await service.assignGeneralLeader(memberId: m.id);
          } else {
            await service.assignGeneralViceLeader(memberId: m.id);
          }

          Get.back();
          Get.snackbar("Success", "Berhasil diassign");
        },
        child: Text("Assign", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            iconSize: 28,
            onPressed: () {
              showSignOutDialog();
            },
            icon: Icon(Icons.logout_sharp, color: Colors.red),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        shadowColor: Colors.black,
        elevation: 5,
        backgroundColor: Colors.green,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                "Organization Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Divisions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            buildDivisionList(),

            const SizedBox(height: 10),
            Text(
              "Leaders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔥 MEMBER LIST
            buildOrganizationControl(),
            const SizedBox(height: 10),
            Text(
              "Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔥 MEMBER LIST
            buildMemberList(),
          ],
        ),
      ),
    );
  }
}
