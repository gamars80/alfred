import 'package:alfred_clean/features/call/model/product.dart';
import 'package:alfred_clean/features/history/model/care_review.dart';
import 'package:alfred_clean/features/history/model/care_community_post.dart';

class CareHistoryResponse {
  final List<CareHistory> histories;
  final String? nextPageKey;

  CareHistoryResponse({
    required this.histories,
    this.nextPageKey,
  });

  factory CareHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CareHistoryResponse(
      histories: (json['histories'] as List<dynamic>)
          .map((e) => CareHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
}

class CareHistory {
  final int id;
  final int createdAt;
  final String query;
  final String keyword;
  final String status;
  final bool hasRating;
  final int? myRating;
  final List<CareRecommendation> recommendations;
  final String? reason;
  final List<CareReview> reviews;
  final List<CareCommunityPost> communityPosts;

  CareHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.keyword,
    required this.status,
    required this.hasRating,
    this.myRating,
    required this.recommendations,
    this.reason,
    required this.reviews,
    required this.communityPosts,
  });

  CareHistory copyWith({
    List<CareRecommendation>? recommendations,
    bool? hasRating,
    int? myRating,
    String? status,
    List<CareReview>? reviews,
    List<CareCommunityPost>? communityPosts,
  }) {
    return CareHistory(
      id: id,
      createdAt: createdAt,
      query: query,
      keyword: keyword,
      status: status ?? this.status,
      hasRating: hasRating ?? this.hasRating,
      myRating: myRating ?? this.myRating,
      recommendations: recommendations ?? this.recommendations,
      reason: reason,
      reviews: reviews ?? this.reviews,
      communityPosts: communityPosts ?? this.communityPosts,
    );
  }

  factory CareHistory.fromJson(Map<String, dynamic> json) {
    return CareHistory(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      query: json['query'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      status: json['status'] as String? ?? '',
      hasRating: json['hasRating'] as bool? ?? false,
      myRating: json['myRating'] as int?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => CareRecommendation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      reason: json['reason'] as String?,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => CareReview.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      communityPosts: (json['communityPosts'] as List<dynamic>?)
          ?.map((e) => CareCommunityPost.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class CareRecommendation {
  final int id;
  final String productId;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String? productDescription;
  final String source;
  final String mallName;
  final String keyword;
  final int reviewCount;
  final bool liked;

  CareRecommendation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    this.productDescription,
    required this.source,
    required this.mallName,
    required this.keyword,
    required this.reviewCount,
    required this.liked,
  });

  factory CareRecommendation.fromJson(Map<String, dynamic> json) {
    return CareRecommendation(
      id: json['id'] as int? ?? 0,
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] as String? ?? '',
      productPrice: json['productPrice'] as int? ?? 0,
      productLink: json['productLink'] as String? ?? '',
      productImage: json['productImage'] as String? ?? '',
      productDescription: json['productDescription'] as String?,
      source: json['source'] as String? ?? '',
      mallName: json['mallName'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      reviewCount: json['reviewCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
    );
  }

  Product toProduct() {
    return Product(
      recommendationId: id.toString(),
      name: productName,
      productId: productId,
      price: productPrice,
      link: productLink,
      image: productImage,
      reason: '',
      mallName: mallName,
      category: '뷰티케어',
      liked: liked,
      reviewCount: reviewCount,
      source: source,
      productDescription: productDescription,
    );
  }
} 