import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getOrganization() async {
  final doc = await FirebaseFirestore.instance
      .collection('organization')
      .doc('main')
      .get();

  return doc.data();
}

Future<void> updateOrganization(Map<String, dynamic> data) async {
  final user = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance
      .collection('organization')
      .doc('main')
      .update({
    ...data,
    'updatedBy': user!.uid,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  Future<void> toggleFavorite(String memberId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final doc = await userRef.get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (favorites.contains(memberId)) {
      favorites.remove(memberId);
    } else {
      favorites.add(memberId);
    }

    await userRef.update({'favorites': favorites});
  }

  Future<bool> isFavorite(String memberId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    return favorites.contains(memberId);
  }

  Stream<QuerySnapshot> getInactiveMembers() {
    return _db
        .collection('members')
        .where('status', isEqualTo: 'Inactive')
        .snapshots();
  }

  Future<void> setActive(String memberId) async {
    await _db.collection('members').doc(memberId).update({'status': 'Active'});
  }

  Future<void> deactivateMember(Member member) async {
    final batch = _db.batch();

    if (member.role == "Ketua" && member.divisionId.isNotEmpty) {
      await removeLeader(member.divisionId);
    }

    if (member.role == "Wakil" && member.divisionId.isNotEmpty) {
      await removeViceLeader(member.divisionId);
    }

    final ref = _db.collection('members').doc(member.id);

    batch.update(ref, {
      'status': 'Inactive',
      'divisionId': '',
      'role': 'Anggota',
    });

    await batch.commit();
  }

  Future<void> assignLeader({
    required String divisionId,
    required String memberId,
  }) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();

    final oldLeaderId = doc.data()?['leaderId'];

    final batch = _db.batch();

    // 🔥 turunkan leader lama
    if (oldLeaderId != '' && oldLeaderId != memberId) {
      final oldLeaderRef = _db.collection('members').doc(oldLeaderId);

      batch.update(oldLeaderRef, {'role': 'Anggota'});
    }

    // 🔥 set leader baru
    batch.update(divisionRef, {'leaderId': memberId});

    final newLeaderRef = _db.collection('members').doc(memberId);

    batch.update(newLeaderRef, {'role': 'Ketua'});

    await batch.commit();
  }

  Future<void> assignViceLeader({
    required String divisionId,
    required String memberId,
  }) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();

    final oldViceId = doc.data()?['viceLeaderId'];

    final batch = _db.batch();

    // 🔥 turunkan wakil lama
    if (oldViceId != '' && oldViceId != memberId) {
      final oldViceRef = _db.collection('members').doc(oldViceId);

      batch.update(oldViceRef, {'role': 'Anggota'});
    }

    // 🔥 set wakil baru
    batch.update(divisionRef, {'viceLeaderId': memberId});

    final newViceRef = _db.collection('members').doc(memberId);

    batch.update(newViceRef, {'role': 'Wakil'});

    await batch.commit();
  }

  Future<void> removeLeader(String divisionId) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();
    final leaderId = doc.data()?['leaderId'];

    final batch = _db.batch();

    if (leaderId != '') {
      final memberRef = _db.collection('members').doc(leaderId);

      batch.update(memberRef, {'role': 'Anggota'});
    }

    batch.update(divisionRef, {'leaderId': ''});

    await batch.commit();
  }

  Future<void> removeViceLeader(String divisionId) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();
    final viceId = doc.data()?['viceLeaderId'];

    final batch = _db.batch();

    if (viceId != '') {
      final memberRef = _db.collection('members').doc(viceId);

      batch.update(memberRef, {'role': 'Anggota'});
    }

    batch.update(divisionRef, {'viceLeaderId': ''});

    await batch.commit();
  }

  Future<void> deleteDivision(String divisionId) async {
    final db = FirebaseFirestore.instance;

    final batch = db.batch();

    // 🔥 ambil semua member di division ini
    final members = await db
        .collection('members')
        .where('divisionId', isEqualTo: divisionId)
        .get();

    for (var m in members.docs) {
      final ref = db.collection('members').doc(m.id);

      batch.update(ref, {
        'divisionId': '',
        'role': 'Anggota', // reset role
      });
    }

    // 🔥 hapus division
    final divisionRef = db.collection('divisions').doc(divisionId);
    batch.delete(divisionRef);

    await batch.commit();
  }

  // 🔥 ADD DIVISION
  Future<void> addDivision(String name, String desc) async {
    await _db.collection('divisions').add({
      'name': name,
      'leaderId': '',
      'viceLeaderId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'description': desc,
    });
  }

  // 🔥 GET DIVISIONS (STREAM)
  Stream<QuerySnapshot> getDivisions() {
    return _db.collection('divisions').snapshots();
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
