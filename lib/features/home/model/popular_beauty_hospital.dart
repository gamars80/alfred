class PopularBeautyHospital {
  final int hospitalId;
  final String source;
  final String title;
  final String thumbnailUrl;
  final String location;
  final String hospitalName;
  final String rating;
  final int ratingCount;
  final String description;
  final int counselCount;
  final int eventCount;
  final int doctorCount;
  final String historyAddedAt;

  PopularBeautyHospital({
    required this.hospitalId,
    required this.source,
    required this.title,
    required this.thumbnailUrl,
    required this.location,
    required this.hospitalName,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.counselCount,
    required this.eventCount,
    required this.doctorCount,
    required this.historyAddedAt,
  });

  factory PopularBeautyHospital.fromJson(Map<String, dynamic> json) {
    return PopularBeautyHospital(
      hospitalId: json['hospitalId'] as int,
      source: json['source'] as String,
      title: json['title'] as String,
      // ↓ 여기만 변경
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      location: json['location'] as String,
      hospitalName: json['hospitalName'] as String,
      rating: json['rating'].toString(),
      ratingCount: json['ratingCount'] as int,
      description: json['description'] as String,
      counselCount: json['counselCount'] as int,
      eventCount: json['eventCount'] as int,
      doctorCount: json['doctorCount'] as int,
      historyAddedAt: json['historyAddedAt'] as String? ?? '',
    );
  }
}
