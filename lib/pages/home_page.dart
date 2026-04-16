import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _homePageState();
  }

  const HomePage({super.key});
}

class _homePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Organization")),
      body: Padding(
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

            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.structure);
              },
              child: Text("Lihat Struktur Organisasi"),
            ),
          ],
        ),
      ),
    );
  }
}
