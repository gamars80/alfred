class Doctor {
  final int id;
  final String name;
  final String specialist;
  final String position;
  final String? profilePhoto;

  Doctor({
    required this.id,
    required this.name,
    required this.specialist,
    required this.position,
    this.profilePhoto,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      name: json['name'] as String,
      specialist: json['specialist'] as String,
      position: json['position'] as String,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
} 