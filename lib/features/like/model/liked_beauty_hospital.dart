class LikedBeautyHospital {
  final int hospitalId;
  final String source;
  final String title;
  final List<String>? thumbnailUrls; // ⬅ null 허용
  final String location;
  final String hospitalName;
  final String rating;
  final int ratingCount;
  final String description;
  final int counselCount;
  final int eventCount;
  final int doctorCount;
  final String historyAddedAt;
  final DateTime likedAt;

  LikedBeautyHospital({
    required this.hospitalId,
    required this.source,
    required this.title,
    required this.thumbnailUrls,
    required this.location,
    required this.hospitalName,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.counselCount,
    required this.eventCount,
    required this.doctorCount,
    required this.historyAddedAt,
    required this.likedAt,
  });

  factory LikedBeautyHospital.fromJson(Map<String, dynamic> json) {
    return LikedBeautyHospital(
      hospitalId: json['eventId'] as int,
      source: json['source'] as String,
      title: json['title'] as String,
      thumbnailUrls: (json['thumbnailUrls'] as List?)?.map((e) => e.toString()).toList(),
      location: json['location'] as String,
      hospitalName: json['hospitalName'] as String,
      rating: json['rating'].toString(),  // 안전하게 toString()
      ratingCount: json['ratingCount'] as int,
      description: json['description']?.toString() ?? '', // 💥 여기를 수정!
      counselCount: json['counselCount'] as int,
      eventCount: json['eventCount'] as int,
      doctorCount: json['doctorCount'] as int,
      historyAddedAt: json['historyAddedAt'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}
