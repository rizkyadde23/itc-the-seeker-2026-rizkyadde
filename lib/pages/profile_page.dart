import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seeker/routes/app_routes.dart';

import '../services/firestore_service.dart';
import '../models/member_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService service = FirestoreService();

  Future<Member?>? memberFuture;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final data = await service.getUserData(currentUser.uid);

    final argMemberId = Get.arguments;
    final targetMemberId = argMemberId != null
        ? argMemberId
        : data!['memberId'];

    setState(() {
      userData = data;
      memberFuture = service.getMemberById(targetMemberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(body: Center(child: Text("User belum login")));
    }

    if (memberFuture == null || userData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myMemberId = userData!['memberId'];
    final role = userData!['role'];

    return FutureBuilder<Member?>(
      future: memberFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final member = snapshot.data!;

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
                      ? Icon(Icons.person, size: 40)
                      : null,
                ),

                SizedBox(height: 10),

                Text(
                  member.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Text(member.role),

                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    member.bio.isNotEmpty ? member.bio : "Belum ada bio",
                  ),
                ),

                Divider(),

                StreamBuilder(
                  stream: service.getDivisions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(
                        leading: Icon(Icons.person_2_rounded),
                        title: Text("Loading..."),
                      );
                    }

                    final divisions = snapshot.data!.docs;

                    // 🔥 MAP ID → NAME
                    final divisionMap = {
                      for (var d in divisions) d.id: d['name'],
                    };

                    final divisionName = divisionMap[member.divisionId] ?? '-';

                    return ListTile(
                      leading: Icon(Icons.apartment),
                      title: Text(divisionName),
                    );
                  },
                ),

                ListTile(leading: Icon(Icons.email), title: Text(member.email)),

                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(member.phone.isNotEmpty ? member.phone : "-"),
                ),

                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text(
                    member.instagram.isNotEmpty ? member.instagram : "-",
                  ),
                ),

                SizedBox(height: 20),

                if (isOwner || isAdmin)
                  ElevatedButton(
                    onPressed: () async {
                      await Get.toNamed(
                        AppRoutes.editProfile,
                        arguments: member,
                      );
                      loadData();
                    },
                    child: Text("Edit Profile"),
                  ),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
