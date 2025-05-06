class Hospital {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String location;
  final String hospitalName;
  final String rating;
  final int ratingCount;
  final int counselCount;
  final int doctorCount;
  final String description;


  Hospital({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.location,
    required this.hospitalName,
    required this.rating,
    required this.ratingCount,
    required this.counselCount,
    required this.doctorCount,
    required this.description,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      location: json['location'],
      hospitalName: json['hospitalName'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      counselCount: json['counselCount'],
      doctorCount: json['doctorCount'],
      description: json['description'],
    );
  }

}
