import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';

class StructurePage extends StatelessWidget {
  const StructurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struktur Organisasi")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('divisions').snapshots(),
        builder: (context, divisionSnapshot) {
          if (!divisionSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final divisions = divisionSnapshot.data!.docs;

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('members')
                .snapshots(),
            builder: (context, memberSnapshot) {
              if (!memberSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final members = memberSnapshot.data!.docs;

              // 🔥 GROUP MEMBERS BY DIVISION
              Map<String, List<QueryDocumentSnapshot>> grouped = {};

              for (var m in members) {
                final divisionId = m['divisionId'] ?? '';

                if (!grouped.containsKey(divisionId)) {
                  grouped[divisionId] = [];
                }

                grouped[divisionId]!.add(m);
              }

              return ListView.builder(
                itemCount: divisions.length,
                itemBuilder: (context, index) {
                  final division = divisions[index];
                  final divisionId = division.id;

                  final divisionMembers = grouped[divisionId] ?? [];

                  return DivisionCardOptimized(
                    division: division,
                    divisionId: divisionId,
                    members: divisionMembers,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DivisionCardOptimized extends StatelessWidget {
  final QueryDocumentSnapshot division;
  final List<QueryDocumentSnapshot> members;
  final String divisionId;

  const DivisionCardOptimized({
    super.key,
    required this.division,
    required this.divisionId,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final leaderId = division['leaderId'];
    final viceLeaderId = division['viceLeaderId'];
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.divisionDesc, arguments: divisionId);
      },
      child: Card(
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 NAMA DIVISI
              Text(
                division['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // 🔥 LEADER (NO QUERY 🔥)
              if (leaderId != '')
                Text(
                  "👑 Ketua: ${_getLeaderName()}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )
              else
                Text("👑 Belum ada ketua"),

              if (viceLeaderId != '')
                Text(
                  "👑 Wakil Ketua: ${_getViceLeaderName()}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )
              else
                Text("👑 Belum ada Wakil Ketua"),

              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              // 🔥 MEMBER LIST
              if (members.isEmpty)
                Text("Belum ada anggota")
              else
                Column(
                  children: members.map((m) {
                    final isLeader = m.id == leaderId;

                    return ListTile(
                      leading: Icon(
                        isLeader ? Icons.star : Icons.person,
                        color: isLeader ? Colors.amber : null,
                      ),
                      title: Text(m['name']),
                      subtitle: Text(m['role']),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLeaderName() {
    try {
      final leader = members.firstWhere((m) => m.id == division['leaderId']);
      return leader['name'];
    } catch (e) {
      return "Belum Ada";
    }
  }

  String _getViceLeaderName() {
    try {
      final vice = members.firstWhere((m) => m.id == division['viceLeaderId']);
      return vice['name'];
    } catch (e) {
      return "Belum ada";
    }
  }
}
