import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/controllers/home_controller.dart';
import 'package:seeker/pages/profile_page.dart';
import 'package:seeker/pages/structure_page.dart';

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
        ],
      ),
    ),
  );
}
