// lib/features/event/model/popular_event.dart
class PopularEvent {
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

  PopularEvent({
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
  });

  factory PopularEvent.fromJson(Map<String, dynamic> json) => PopularEvent(
    eventId: json['eventId'],
    source: json['source'],
    cnt: json['cnt'],
    title: json['title'],
    location: json['location'],
    hospitalName: json['hospitalName'],
    thumbnailUrl: json['thumbnailUrl'],
    discountedPrice: json['discountedPrice'],
    discountRate: (json['discountRate'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    ratingCount: json['ratingCount'],
    description: json['description'],
    detailImage: json['detailImage'],
  );
}