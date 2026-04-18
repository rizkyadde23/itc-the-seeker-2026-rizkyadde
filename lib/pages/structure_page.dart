import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seeker/routes/app_routes.dart';

class StructurePage extends StatelessWidget {
  const StructurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Struktur Organisasi")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, favSnapshot) {
          if (!favSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favData = favSnapshot.data!.data() as Map<String, dynamic>;
          final favorites = List<String>.from(favData['favorites'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('divisions')
                .snapshots(),
            builder: (context, divisionSnapshot) {
              if (!divisionSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final divisions = divisionSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('members')
                    .snapshots(),
                builder: (context, memberSnapshot) {
                  if (!memberSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
                        favorites: favorites,
                      );
                    },
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
  final List<String> favorites;

  const DivisionCardOptimized({
    super.key,
    required this.division,
    required this.divisionId,
    required this.members,
    required this.favorites,
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
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 NAMA DIVISI
              Text(
                division['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 LEADER
              Text(
                leaderId != ''
                    ? "👑 Ketua: ${_getLeaderName()}"
                    : "👑 Belum ada ketua",
              ),

              Text(
                viceLeaderId != ''
                    ? "👑 Wakil: ${_getViceLeaderName()}"
                    : "👑 Belum ada wakil",
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // 🔥 MEMBER LIST
              if (members.isEmpty)
                const Text("Belum ada anggota")
              else
                Column(
                  children: members.map((m) {
                    final isLeader = m.id == leaderId;
                    final isFav = favorites.contains(m.id);

                    return ListTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.profile, arguments: m.id);
                      },
                      leading: Icon(
                        isLeader ? Icons.star : Icons.person,
                        color: isLeader ? Colors.amber : null,
                      ),
                      title: Text(m['name']),
                      subtitle: Text(m['role']),

                      // 🔥 FAVORITE BUTTON
                      trailing: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () async {
                          final userRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid);

                          final doc = await userRef.get();
                          final favs = List<String>.from(
                            doc.data()?['favorites'] ?? [],
                          );

                          if (favs.contains(m.id)) {
                            favs.remove(m.id);
                          } else {
                            favs.add(m.id);
                          }

                          await userRef.update({'favorites': favs});
                        },
                      ),
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
      return "Belum ada";
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
