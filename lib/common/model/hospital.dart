class Hospital {
  final int id;
  final String name;
  final String? image;
  final String? region;

  Hospital({
    required this.id,
    required this.name,
    this.image,
    this.region,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      region: json['region'] as String?,
    );
  }
} 