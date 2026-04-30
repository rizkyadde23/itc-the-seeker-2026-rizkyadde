class Member {
  final String id;
  final String name;
  final String role;
  final String globalRole;
  final String divisionId;
  final String status;
  final String photoUrl;
  final String periodId;

  final String bio;
  final String email;
  final String phone;
  final String instagram;

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.globalRole,
    required this.divisionId,
    required this.status,
    required this.photoUrl,
    required this.periodId,
    required this.bio,
    required this.email,
    required this.phone,
    required this.instagram,
  });

  factory Member.fromMap(Map<String, dynamic> data, String id) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      globalRole: data['globalRole'] ?? '',
      divisionId: data['divisionId'] ?? '',
      status: data['status'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      periodId: data['periodId'] ?? '',
      bio: data['bio'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      instagram: data['instagram'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'globalRole': globalRole,
      'divisionId': divisionId,
      'status': status,
      'photoUrl': photoUrl,
      'periodId': periodId,
      'bio': bio,
      'email': email,
      'phone': phone,
      'instagram': instagram,
    };
  }
}
