import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DivisionPage extends StatelessWidget {
  const DivisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? divisionId = Get.arguments;
    print("Division ID = $divisionId");

    if (divisionId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Division")),
        body: const Center(child: Text("Division tidak ditemukan")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Division")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDivisionDetail(divisionId),
            const SizedBox(height: 16),
            Text(
              "Daftar Member",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMemberList(divisionId),
          ],
        ),
      ),
    );
  }

  // 🔥 DETAIL DIVISION
  Widget _buildDivisionDetail(String divisionId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('divisions')
          .doc(divisionId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.greenAccent,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(192, 84, 84, 84),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'].toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(data['description']),
            ],
          ),
        );
      },
    );
  }

  // 🔥 LIST MEMBER BY DIVISION
  Widget _buildMemberList(String divisionId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('divisionId', isEqualTo: divisionId)
          .where('status', isEqualTo: 'Active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final members = snapshot.data!.docs;

        if (members.isEmpty) {
          return const Text("Belum ada anggota");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final doc = members[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              color: Colors.white,
              shadowColor: Colors.black,
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'] ?? '-'),
                subtitle: Text(data['role'] ?? '-'),
                onTap: () {
                  Get.toNamed(
                    '/profile',
                    arguments: doc.id, // 🔥 kirim memberId
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
