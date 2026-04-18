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
  double? deviceWidth, deviceHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ITC Directory",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
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
    );
  }

  Widget HomeTab(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Tentang ITC")),
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
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent dictum pellentesque magna, non condimentum velit commodo id. Phasellus ac libero at odio vehicula accumsan in in arcu. Nulla pretium elit nec placerat ornare. Suspendisse bibendum quam non elit tempus, vel fermentum nisl commodo. Aliquam ut facilisis elit. Duis arcu lectus, molestie eget gravida quis, hendrerit a odio. Duis id tortor quis risus imperdiet mattis. Proin laoreet lacus sed facilisis lobortis. Aliquam ligula nisl, scelerisque luctus sapien in, scelerisque aliquam metus. Vivamus accumsan rhoncus eros non ullamcorper.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent dictum pellentesque magna, non condimentum velit commodo id. Phasellus ac libero at odio vehicula accumsan in in arcu. Nulla pretium elit nec placerat ornare. Suspendisse bibendum quam non elit tempus, vel fermentum nisl commodo. Aliquam ut facilisis elit. Duis arcu lectus, molestie eget gravida quis, hendrerit a odio. Duis id tortor quis risus imperdiet mattis. Proin laoreet lacus sed facilisis lobortis. Aliquam ligula nisl, scelerisque luctus sapien in, scelerisque aliquam metus. Vivamus accumsan rhoncus eros non ullamcorper.",
                textAlign: TextAlign.justify,
              ),

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

              Text(
                "Wakil Ketua",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                ),
                title: Text("Nama Wakil Ketua"),
                subtitle: Text("Wakil Ketua Umum"),
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
      ),
    );
  }
}
