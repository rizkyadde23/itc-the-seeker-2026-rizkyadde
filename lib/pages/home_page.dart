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
  bool isLeader = false;

  double? deviceWidth, deviceHeight;

  final FirestoreService service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        shadowColor: Colors.black,
        elevation: 5,
        centerTitle: true,
        title: Text(
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
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 65, 65, 65),
                spreadRadius: 0.5,
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            elevation: 5,
            iconSize: 28,
            backgroundColor: Colors.white,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.home_sharp, color: Colors.green),
                icon: Icon(
                  Icons.home_outlined,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.account_tree, color: Colors.green),
                icon: Icon(Icons.account_tree_outlined, color: Colors.black),
                label: "Structure",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.person, color: Colors.green),
                icon: Icon(Icons.person_2_outlined, color: Colors.black),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkGeneralLeader() async {
    final generalRole = await service.getCurrentGlobalRole();
    setState(() {
      isLeader =
          (generalRole == "Ketua Umum" || generalRole == "Wakil Ketua Umum");
    });
  }

  Widget HomeTab(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          "Profil Organisasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        ),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: service.getOrganization(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();

                  final org = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(org['description']),
                      SizedBox(height: 8),
                      Text(
                        "Visi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(org['vision']),
                      SizedBox(height: 8),
                      Text(
                        "Misi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      Text(org['mission']),
                      SizedBox(height: 8),
                      if (isLeader)
                        MaterialButton(
                          color: Colors.green,
                          onPressed: () {
                            Get.toNamed(AppRoutes.editOrganization);
                          },
                          child: Text("Edit Organisasi"),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20),

              Text(
                "Ketua",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                shadowColor: Colors.black,
                elevation: 8,
                color: const Color.fromARGB(255, 51, 120, 53),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                  ),
                  title: Text(
                    "Nama Ketua",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Ketua Umum",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text(
                "Wakil Ketua",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                color: Colors.greenAccent,
                shadowColor: Colors.black,
                elevation: 8,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                  ),
                  title: Text(
                    "Nama Wakil Ketua",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text("Wakil Ketua Umum,"),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Favorite",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      ...favorites.map((id) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('members')
                              .doc(id)
                              .get(),
                          builder: (context, snap) {
                            if (!snap.hasData) return SizedBox();

                            final m = snap.data!;

                            return Card(
                              color: Colors.white,
                              shadowColor: Colors.black,
                              elevation: 5,
                              child: ListTile(
                                title: Text(m['name']),
                                trailing: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.profile,
                                    arguments: m.id,
                                  );
                                },
                              ),
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
      ),
    );
  }
}
