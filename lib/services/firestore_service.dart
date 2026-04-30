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

    if (member.role == "Kepala Divisi" && member.divisionId.isNotEmpty) {
      await removeHead(member.divisionId);
    }

    if (member.role == "Wakil Kepala Divisi" && member.divisionId.isNotEmpty) {
      await removeViceHead(member.divisionId);
    }

    if (member.globalRole == "Ketua Umum" && member.id.isNotEmpty) {
      await removeGeneralLeader();
    }

    if (member.globalRole == "Wakil Ketua Umum" && member.id.isNotEmpty) {
      await removeGeneralViceLeader();
    }

    final ref = _db.collection('members').doc(member.id);

    batch.update(ref, {
      'status': 'Inactive',
      'divisionId': '',
      'role': 'Anggota',
      'globalRole': 'General',
    });

    await batch.commit();
  }

  Future<void> assignHead({
    required String divisionId,
    required String memberId,
  }) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();

    final oldHeadId = doc.data()?['headId'];

    final batch = _db.batch();

    // 🔥 turunkan leader lama
    if (oldHeadId != '' && oldHeadId != memberId) {
      final oldLeaderRef = _db.collection('members').doc(oldHeadId);

      batch.update(oldLeaderRef, {'role': 'Anggota'});
    }

    // 🔥 set leader baru
    batch.update(divisionRef, {'headId': memberId});

    final newLeaderRef = _db.collection('members').doc(memberId);

    batch.update(newLeaderRef, {'role': 'Kepala Divisi'});

    await batch.commit();
  }

  Future<void> assignViceHead({
    required String divisionId,
    required String memberId,
  }) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();

    final oldViceId = doc.data()?['viceHeadId'];

    final batch = _db.batch();

    // 🔥 turunkan wakil lama
    if (oldViceId != '' && oldViceId != memberId) {
      final oldViceRef = _db.collection('members').doc(oldViceId);

      batch.update(oldViceRef, {'role': 'Anggota'});
    }

    // 🔥 set wakil baru
    batch.update(divisionRef, {'viceHeadId': memberId});

    final newViceRef = _db.collection('members').doc(memberId);

    batch.update(newViceRef, {'role': 'Wakil Kepala Divisi'});

    await batch.commit();
  }

  Future<void> removeHead(String divisionId) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();
    final leaderId = doc.data()?['headId'];

    final batch = _db.batch();

    if (leaderId != '') {
      final memberRef = _db.collection('members').doc(leaderId);

      batch.update(memberRef, {'role': 'Anggota'});
    }

    batch.update(divisionRef, {'headId': ''});

    await batch.commit();
  }

  Future<void> removeViceHead(String divisionId) async {
    final divisionRef = _db.collection('divisions').doc(divisionId);

    final doc = await divisionRef.get();
    final viceId = doc.data()?['viceHeadId'];

    final batch = _db.batch();

    if (viceId != '') {
      final memberRef = _db.collection('members').doc(viceId);

      batch.update(memberRef, {'role': 'Anggota'});
    }

    batch.update(divisionRef, {'viceHeadId': ''});

    await batch.commit();
  }

 Future<void> assignGeneralLeader({
  required String memberId,
}) async {
  final orgRef = _db.collection('organization').doc('main');
  final membersRef = _db.collection('members');

  final doc = await orgRef.get();
  final oldLeaderId = doc.data()?['leaderId'];

  final batch = _db.batch();

  // 🔥 reset leader lama
  if (oldLeaderId != null && oldLeaderId != '') {
    final oldRef = membersRef.doc(oldLeaderId);
    batch.update(oldRef, {'globalRole': ''});
  }

  // 🔥 set leader baru
  final newRef = membersRef.doc(memberId);
  batch.update(newRef, {'globalRole': 'Ketua Umum'});

  batch.update(orgRef, {'leaderId': memberId});

  await batch.commit();
}

  Future<void> assignGeneralViceLeader({
  required String memberId,
}) async {
  final orgRef = _db.collection('organization').doc('main');
  final membersRef = _db.collection('members');

  final doc = await orgRef.get();
  final oldId = doc.data()?['viceLeaderId'];

  final batch = _db.batch();

  if (oldId != null && oldId != '') {
    batch.update(membersRef.doc(oldId), {'globalRole': ''});
  }

  batch.update(membersRef.doc(memberId), {
    'globalRole': 'Wakil Ketua Umum',
  });

  batch.update(orgRef, {'viceLeaderId': memberId});

  await batch.commit();
}

 Future<void> removeGeneralLeader() async {
  final orgRef = _db.collection('organization').doc('main');

  final doc = await orgRef.get();
  final leaderId = doc.data()?['leaderId'];

  final batch = _db.batch();

  if (leaderId != null && leaderId != '') {
    final memberRef = _db.collection('members').doc(leaderId);

    // 🔥 reset globalRole di member
    batch.update(memberRef, {'globalRole': 'General'});
  }

  // 🔥 reset di organization
  batch.update(orgRef, {'leaderId': ''});

  await batch.commit();
}

 Future<void> removeGeneralViceLeader() async {
  final orgRef = _db.collection('organization').doc('main');

  final doc = await orgRef.get();
  final viceId = doc.data()?['viceLeaderId'];

  final batch = _db.batch();

  if (viceId != null && viceId != '') {
    final memberRef = _db.collection('members').doc(viceId);

    batch.update(memberRef, {'globalRole': 'General'});
  }

  batch.update(orgRef, {'viceLeaderId': ''});

  await batch.commit();
}

Future<void> syncOrganizationRoles() async {
  final orgRef = _db.collection('organization').doc('main');
  final membersRef = _db.collection('members');

  final orgDoc = await orgRef.get();
  final leaderId = orgDoc.data()?['leaderId'];
  final viceId = orgDoc.data()?['viceLeaderId'];

  final members = await membersRef.get();

  final batch = _db.batch();

  for (var m in members.docs) {
    final id = m.id;
    final role = m['globalRole'] ?? 'General';

    // 🔥 FIX Ketua Umum
    if (id == leaderId) {
      if (role != 'Ketua Umum') {
        batch.update(m.reference, {'globalRole': 'Ketua Umum'});
      }
    } else if (role == 'Ketua Umum') {
      batch.update(m.reference, {'globalRole': 'General'});
    }

    // 🔥 FIX Wakil
    if (id == viceId) {
      if (role != 'Wakil Ketua Umum') {
        batch.update(m.reference, {
          'globalRole': 'Wakil Ketua Umum',
        });
      }
    } else if (role == 'Wakil Ketua Umum') {
      batch.update(m.reference, {'globalRole': 'General'});
    }
  }

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
      'headId': '',
      'viceHeadId': '',
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

  Future<String> getCurrentGlobalRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await _db.collection('members').doc(uid).get();
    return doc['globalRole'];
  }

  Future<void> updateMemberPartial(
    String memberId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('members').doc(memberId).update(data);
  }
}
