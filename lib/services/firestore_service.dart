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

  //Crud
  Future<void> addMember(Member member) async {
    await _db.collection('members').add(member.toMap());
  }

  Future<void> updateMember(String id, Member member) async {
    await _db.collection('members').doc(id).update(member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await _db.collection('members').doc(id).delete();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<Member?> getMemberById(String id) async {
    final doc = await _db.collection('members').doc(id).get();

    if (doc.exists) {
      return Member.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
