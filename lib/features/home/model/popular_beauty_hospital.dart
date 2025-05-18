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
      hospitalId: json['hospitalId'],
      source: json['source'],
      title: json['title'],
      thumbnailUrl: (json['thumbnailUrls'] as List).isNotEmpty ? json['thumbnailUrls'][0] : '',
      location: json['location'],
      hospitalName: json['hospitalName'],
      rating: json['rating'].toString(),
      ratingCount: json['ratingCount'],
      description: json['description'],
      counselCount: json['counselCount'],
      eventCount: json['eventCount'],
      doctorCount: json['doctorCount'],
      historyAddedAt: json['historyAddedAt'],
    );
  }
}
