class Hospital {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? imageUrl;

  Hospital({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.imageUrl,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
} 