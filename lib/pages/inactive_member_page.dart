import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';
import 'package:get/get.dart';

class InactiveMembersPage extends StatelessWidget {
  final FirestoreService service = FirestoreService();

  InactiveMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Member Inactive")),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getInactiveMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada member inactive"));
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
              final m = members[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text(m.name[0])),
                  title: Text(m.name),
                  subtitle: Text("Status: ${m.status}"),

                  // 🔥 tombol aktifkan lagi
                  trailing: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.green),
                    onPressed: () async {
                      await service.updateMemberPartial(m.id, {
                        'status': 'Active',
                      });
                      Get.snackbar("Berhasil", "Member Telah Diaktifkan lagi");
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
