import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  // 🔥 ADD DIVISION
  Future<void> addDivision(String name) async {
    await _db.collection('divisions').add({
      'name': name,
      'leaderId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 GET DIVISIONS (STREAM)
  Stream<QuerySnapshot> getDivisions() {
    return _db.collection('divisions').snapshots();
  }

  // 🔥 SET LEADER
  Future<void> setLeader(String divisionId, String memberId) async {
    await _db.collection('divisions').doc(divisionId).update({
      'leaderId': memberId,
    });
  }

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
  Future<String> createMember(Member member) async {
    final doc = await _db.collection('members').add(member.toMap());
    return doc.id;
  }

  Future<void> createUser(String uid, String email, String memberId) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': 'user',
      'memberId': memberId,
    });
  }

  Future<void> addMember(Member member) async {
    await _db.collection('members').add(member.toMap());
  }

  Future<void> updateMember(String id, Map<String, dynamic> data) async {
  await _db.collection('members').doc(id).update(data);
}

  Future<void> deleteMember(String id) async {
    await _db.collection('members').doc(id).delete();
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
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


Future<String> getCurrentUserRole() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await _db.collection('users').doc(uid).get();

  return doc['role'];
}

Future<void> updateMemberPartial(
  String memberId,
  Map<String, dynamic> data,
) async {
  await _db.collection('members').doc(memberId).update(data);
}

}
