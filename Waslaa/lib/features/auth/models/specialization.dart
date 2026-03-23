class Specialization {
  const Specialization({required this.id, required this.name});

  final int id;
  final String name;

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
    );
  }
}