import 'package:flutter/foundation.dart';
import '../../../common/model/doctor.dart';
import '../../../common/model/hospital.dart';
import '../../../common/model/event.dart';

class KeywordReviewImage {
  final String id;
  final String url;
  final String smallUrl;
  final bool isAfter;
  final int order;
  final bool isMain;
  final bool isBlur;

  KeywordReviewImage({
    required this.id,
    required this.url,
    required this.smallUrl,
    required this.isAfter,
    required this.order,
    required this.isMain,
    required this.isBlur,
  });

  factory KeywordReviewImage.fromJson(Map<String, dynamic> json) {
    return KeywordReviewImage(
      id: json['id'] as String,
      url: json['url'] as String,
      smallUrl: json['smallUrl'] as String,
      isAfter: json['isAfter'] as bool,
      order: json['order'] as int,
      isMain: json['isMain'] as bool,
      isBlur: json['isBlur'] as bool,
    );
  }
}

class KeywordReview {
  final String id;
  final int reviewId;
  final String keyword;
  final String source;
  final List<String> categories;
  final String createdAt;
  final int rating;
  final String text;
  final List<KeywordReviewImage> images;
  final int price;
  final Event? event;
  final Doctor? doctor;
  final Hospital? hospital;

  KeywordReview({
    required this.id,
    required this.reviewId,
    required this.keyword,
    required this.source,
    required this.categories,
    required this.createdAt,
    required this.rating,
    required this.text,
    required this.images,
    required this.price,
    this.event,
    this.doctor,
    this.hospital,
  });

  factory KeywordReview.fromJson(Map<String, dynamic> json) {
    return KeywordReview(
      id: json['id'] as String,
      reviewId: json['reviewId'] as int,
      keyword: json['keyword'] as String,
      source: json['source'] as String,
      categories: (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['createdAt'] as String,
      rating: json['rating'] as int,
      text: json['text'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => KeywordReviewImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: json['price'] as int,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      hospital: json['hospital'] != null ? Hospital.fromJson(json['hospital']) : null,
    );
  }
} 