import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Ambil semua member
  Future<List<Member>> getMembers() async {
    final snapshot = await _db.collection('members').get();

    return snapshot.docs
        .map((doc) => Member.fromMap(doc.data(), doc.id))
        .toList();
  }

  // 🔥 Filter by division (dipakai nanti)
  Future<List<Member>> getMembersByDivision(String divisionId) async {
    final snapshot = await _db
        .collection('members')
        .where('divisionId', isEqualTo: divisionId)
        .get();

    return snapshot.docs
        .map((doc) => Member.fromMap(doc.data(), doc.id))
        .toList();
  }
}