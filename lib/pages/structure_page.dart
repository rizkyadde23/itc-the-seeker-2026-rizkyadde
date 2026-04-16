import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../models/member_model.dart';

class StructurePage extends StatelessWidget {
  StructurePage({super.key});
  final service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struktur Organisasi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data!.docs
              .map(
                (doc) =>
                    Member.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();

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
