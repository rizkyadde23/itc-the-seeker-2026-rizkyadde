class Division {
  final String id;
  final String name;
  final String description;

  Division({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Division.fromMap(Map<String, dynamic> data, String id) {
    return Division(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }
}