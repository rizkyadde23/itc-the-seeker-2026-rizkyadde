import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/controllers/home_controller.dart';
import 'package:seeker/pages/profile_page.dart';
import 'package:seeker/pages/structure_page.dart';
import 'package:seeker/routes/app_routes.dart';
import 'package:seeker/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(HomeController());
  final FirestoreService service = FirestoreService();

  bool isLeader = false;

  double? deviceWidth, deviceHeight;

  @override
  void initState() {
    super.initState();
    checkGeneralLeader();
  }

  Future<void> checkGeneralLeader() async {
    final generalRole = await service.getCurrentGlobalRole();
    setState(() {
      isLeader =
          (generalRole == "Ketua Umum" || generalRole == "Wakil Ketua Umum");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        shadowColor: Colors.black,
        elevation: 5,
        centerTitle: true,
        title: const Text(
          "ITC DIRECTORY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: [HomeTab(context), StructurePage(), ProfilePage()],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: Colors.green),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined),
              activeIcon: Icon(Icons.account_tree, color: Colors.green),
              label: "Structure",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person, color: Colors.green),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget HomeTab(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(
          "Profil Organisasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 ORGANIZATION + LEADER STREAM
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('organization')
                  .doc('main')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final org = snapshot.data!.data() as Map<String, dynamic>;

                final leaderId = org['leaderId'] ?? '';
                final viceLeaderId = org['viceLeaderId'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 ORG INFO
                    Text(
                      org['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(org['description']),
                    const SizedBox(height: 8),

                    const Text(
                      "Visi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(org['vision']),

                    const SizedBox(height: 8),
                    const Text(
                      "Misi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(org['mission']),

                    const SizedBox(height: 8),

                    /// 🔥 EDIT BUTTON (ROLE BASED)
                    if (isLeader)
                      MaterialButton(
                        color: Colors.green,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          Get.toNamed(AppRoutes.editOrganization);
                        },
                        child: const Text(
                          "Edit Organisasi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                    const SizedBox(height: 20),

                    /// 🔥 KETUA
                    const Text(
                      "Ketua",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildLeaderCard(leaderId, true),

                    const SizedBox(height: 20),

                    /// 🔥 WAKIL
                    const Text(
                      "Wakil Ketua",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildLeaderCard(viceLeaderId, false),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🔥 FAVORITE SECTION (UNCHANGED)
            const Text(
              "Favorite",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final favorites = List<String>.from(data['favorites'] ?? []);

                if (favorites.isEmpty) {
                  return const Text("Belum ada favorit");
                }

                return Column(
                  children: favorites.map((id) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('members')
                          .doc(id)
                          .get(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox();

                        final m = snap.data!;

                        return Card(
                          child: ListTile(
                            title: Text(m['name']),
                            trailing: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onTap: () {
                              Get.toNamed(AppRoutes.profile, arguments: m.id);
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 WIDGET LEADER (REUSABLE, UI TETAP)
  Widget _buildLeaderCard(String memberId, bool isLeader) {
    if (memberId == '') {
      return Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: ListTile(
          title: Text(isLeader ? "Nama Ketua" : "Nama Wakil Ketua"),
          subtitle: Text(isLeader ? "Ketua Umum" : "Wakil Ketua Umum"),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('members')
          .doc(memberId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text("Loading...")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 5,
          shadowColor: Colors.black,
          color: isLeader
              ? const Color.fromARGB(255, 51, 120, 53)
              : Colors.greenAccent,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            title: Text(
              data['name'],
              style: TextStyle(
                color: isLeader ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              isLeader ? "Ketua Umum" : "Wakil Ketua Umum",
              style: TextStyle(color: isLeader ? Colors.white : Colors.black),
            ),
            onTap: () {
              Get.toNamed(AppRoutes.profile, arguments: memberId);
            },
          ),
        );
      },
    );
  }
}
