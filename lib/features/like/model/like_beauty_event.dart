class LikedBeautyEvent {
  final int eventId;
  final String source;
  final String title;
  final List<String>? thumbnailUrls; // ⬅ null 허용
  final String location;
  final String hospitalName;
  final int discountedPrice;
  final int discountRate;
  final String rating;
  final int ratingCount;
  final String description;
  final String detailImage;
  final String historyAddedAt;
  final DateTime likedAt;

  LikedBeautyEvent({
    required this.eventId,
    required this.source,
    required this.title,
    required this.thumbnailUrls,
    required this.location,
    required this.hospitalName,
    required this.discountedPrice,
    required this.discountRate,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.detailImage,
    required this.historyAddedAt,
    required this.likedAt,
  });

  factory LikedBeautyEvent.fromJson(Map<String, dynamic> json) {
    return LikedBeautyEvent(
      eventId: json['eventId'] as int,
      source: json['source'] as String,
      title: json['title'] as String,
      thumbnailUrls: (json['thumbnailUrls'] as List?)?.map((e) => e.toString()).toList(), // ⬅ null-safe 변환
      location: json['location'] as String,
      hospitalName: json['hospitalName'] as String,
      discountedPrice: json['discountedPrice'] as int,
      discountRate: json['discountRate'] as int,
      rating: json['rating'] as String,
      ratingCount: json['ratingCount'] as int,
      description: json['description'] as String,
      detailImage: json['detailImage'] as String,
      historyAddedAt: json['historyAddedAt'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}
