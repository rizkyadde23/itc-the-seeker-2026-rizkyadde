import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../models/member_model.dart';

class StructurePage extends StatelessWidget {
  final service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struktur Organisasi")),
      body: FutureBuilder<List<Member>>(
        future: service.getMembers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data!;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];

              return ListTile(
                title: Text(member.name),
                subtitle: Text(member.role),
                onTap: () {
                  Get.toNamed(AppRoutes.profile, arguments: member.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}