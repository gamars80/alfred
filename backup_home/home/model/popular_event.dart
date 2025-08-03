// lib/features/event/model/popular_event.dart
class PopularEvent {
  final String userId;
  final int eventId;
  final String source;
  final int cnt;
  final String title;
  final String location;
  final String hospitalName;
  final String thumbnailUrl;
  final String discountedPrice;
  final double discountRate;
  final double rating;
  final int ratingCount;
  final String description;
  final String detailImage;
  final String historyAddedAt;

  PopularEvent({
    required this.userId,
    required this.eventId,
    required this.source,
    required this.cnt,
    required this.title,
    required this.location,
    required this.hospitalName,
    required this.thumbnailUrl,
    required this.discountedPrice,
    required this.discountRate,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.detailImage,
    required this.historyAddedAt,
  });

  factory PopularEvent.fromJson(Map<String, dynamic> json) => PopularEvent(
    userId: json['userId'] as String,
    eventId: json['eventId'] as int,
    source: json['source'] as String?       ?? '',
    cnt: json['cnt'] as int,
    title: json['title'] as String?        ?? '',
    location: json['location'] as String?   ?? '',
    hospitalName: json['hospitalName'] as String? ?? '',
    thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    discountedPrice: json['discountedPrice'] as String? ?? '',
    discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0.0,
    rating:      (json['rating']      as num?)?.toDouble() ?? 0.0,
    ratingCount: json['ratingCount'] as int? ?? 0,
    description: json['description'] as String? ?? '',
    detailImage: json['detailImage'] as String? ?? '',
    historyAddedAt: json['historyAddedAt'] as String? ?? '',
  );
}