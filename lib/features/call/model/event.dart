import 'hostpital.dart';
import 'package:flutter/foundation.dart';

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
  final String? detailLink;

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
    this.detailLink,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    debugPrint('Event.fromJson raw data: $json');
    final detailLink = json['detailLink']?.toString() ?? json['detail_link']?.toString();
    debugPrint('Parsed detailLink: $detailLink');
    
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
      liked: json['liked'] ?? false,
      detailLink: detailLink,
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
      detailLink: detailLink,
    );
  }


}