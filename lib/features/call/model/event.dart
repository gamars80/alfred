import 'hostpital.dart';

class Event {
  final int id;
  final String title;
  final String source;
  final String thumbnailUrl;
  final String location;
  final String hospitalName;
  final int discountedPrice;
  final int discountRate;
  final double? rating;
  final int ratingCount;
  final String detailImage;
  final bool liked;

  Event({
    required this.id,
    required this.title,
    required this.source,
    required this.thumbnailUrl,
    required this.location,
    required this.hospitalName,
    required this.discountedPrice,
    required this.discountRate,
    this.rating,
    required this.ratingCount,
    required this.detailImage,
    required this.liked,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      source: json['source'],
      thumbnailUrl: json['thumbnailUrl'],
      location: json['location'],
      hospitalName: json['hospitalName'],
      discountedPrice: json['discountedPrice'],
      discountRate: json['discountRate'],
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      ratingCount: json['ratingCount'],
      detailImage: json['detailImage'] ?? '',
      liked: json['liked'] ?? false, // 기본 false
    );
  }

  Event copyWith({bool? liked}) {
    return Event(
      id: id,
      title: title,
      source: source,
      thumbnailUrl: thumbnailUrl,
      location: location,
      hospitalName: hospitalName,
      discountedPrice: discountedPrice,
      discountRate: discountRate,
      rating: rating,
      ratingCount: ratingCount,
      detailImage: detailImage,
      liked: liked ?? this.liked,
    );
  }


}