import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/controllers/home_controller.dart';
import 'package:seeker/pages/profile_page.dart';
import 'package:seeker/pages/structure_page.dart';
import 'package:seeker/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  final List<Widget> pages = [HomeTab(), StructurePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_tree),
              label: "Structure",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

Widget HomeTab() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deskripsi Organisasi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Ini adalah deskripsi singkat organisasi..."),

          SizedBox(height: 20),

          Text(
            "Ketua",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            title: Text("Nama Ketua"),
            subtitle: Text("Ketua Umum"),
          ),

          SizedBox(height: 20),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final favorites = List<String>.from(data['favorites'] ?? []);

              if (favorites.isEmpty) {
                return Text("Belum ada favorit");
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⭐ Favorite Members",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  ...favorites.map((id) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('members')
                          .doc(id)
                          .get(),
                      builder: (context, snap) {
                        if (!snap.hasData) return SizedBox();

                        final m = snap.data!;

                        return ListTile(
                          title: Text(m['name']),
                          trailing: Icon(Icons.favorite, color: Colors.red),
                          onTap: () {
                            Get.toNamed(AppRoutes.profile, arguments: m.id);
                          },
                        );
                      },
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
