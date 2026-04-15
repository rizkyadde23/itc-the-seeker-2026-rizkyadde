class Member {
  final String id;
  final String name;
  final String role;
  final String divisionId;
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
    required this.divisionId,
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
    divisionId: data['divisionId'] ?? '',
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
    'divisionId': divisionId,
    'photoUrl': photoUrl,
    'periodId': periodId,
    'bio': bio,
    'email': email,
    'phone': phone,
    'instagram': instagram,
  };
}
}
