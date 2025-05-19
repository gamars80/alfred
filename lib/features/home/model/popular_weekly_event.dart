// lib/features/home/model/popular_weekly_event.dart
class PopularWeeklyEvent {
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

  PopularWeeklyEvent({
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

  factory PopularWeeklyEvent.fromJson(Map<String, dynamic> json) {
    return PopularWeeklyEvent(
      userId: json['userId'],
      eventId: json['eventId'],
      source: json['source'],
      cnt: json['cnt'],
      title: json['title'],
      location: json['location'],
      hospitalName: json['hospitalName'],
      thumbnailUrl: json['thumbnailUrl'],
      discountedPrice: json['discountedPrice'],
      discountRate: json['discountRate'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      description: json['description'],
      detailImage: json['detailImage'],
      historyAddedAt: json['historyAddedAt'],
    );
  }
}
