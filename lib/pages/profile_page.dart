import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../models/member_model.dart';

class ProfilePage extends StatelessWidget {
  final service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final memberId = Get.arguments as String;

    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Member?>(
      future: service.getMemberById(memberId),
      builder: (context, memberSnapshot) {
        if (!memberSnapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final member = memberSnapshot.data!;

        return FutureBuilder<Map<String, dynamic>?>(
          future: service.getUserData(currentUser!.uid),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data!;
            final myMemberId = userData['memberId'];
            final role = userData['role'];

            final isOwner = myMemberId == member.id;
            final isAdmin = role == 'admin';

            return Scaffold(
              appBar: AppBar(title: Text("Profile")),
              body: SingleChildScrollView(
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

                    // 🔥 CONDITIONAL EDIT BUTTON
                    if (isOwner || isAdmin)
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/edit-profile', arguments: member);
                        },
                        child: Text("Edit Profile"),
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
}