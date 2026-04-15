import 'package:flutter/material.dart';
import '../models/member_model.dart';

class ProfilePage extends StatelessWidget {
  final Member member;

  const ProfilePage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // 🔥 FOTO
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(member.photoUrl),
            ),

            SizedBox(height: 10),

            // 🔥 NAMA
            Text(
              member.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // 🔥 ROLE
            Text(member.role),

            SizedBox(height: 20),

            // 🔥 BIO
            Padding(padding: const EdgeInsets.all(16), child: Text(member.bio)),

            Divider(),

            // 🔥 CONTACT
            ListTile(leading: Icon(Icons.email), title: Text(member.email)),

            ListTile(leading: Icon(Icons.phone), title: Text(member.phone)),

            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(member.instagram),
            ),
          ],
        ),
      ),
    );
  }
}
