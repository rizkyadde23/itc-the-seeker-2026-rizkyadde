import 'package:flutter/material.dart';
import '../models/member_model.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../models/member_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final memberId = Get.arguments as String;
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: FutureBuilder<Member?>(
        future: service.getMemberById(memberId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final member = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),

                CircleAvatar(
                  radius: 50,
                  backgroundImage: member.photoUrl.isNotEmpty
                      ? NetworkImage(member.photoUrl)
                      : null,
                  child: member.photoUrl.isEmpty
                      ? Icon(Icons.person)
                      : null,
                ),

                SizedBox(height: 10),

                Text(
                  member.name,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Text(member.role),

                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(member.bio),
                ),

                Divider(),

                ListTile(
                  leading: Icon(Icons.email),
                  title: Text(member.email),
                ),

                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(member.phone),
                ),

                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text(member.instagram),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}