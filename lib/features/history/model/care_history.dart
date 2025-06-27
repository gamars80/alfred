import 'package:alfred_clean/features/call/model/product.dart';

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
  });

  CareHistory copyWith({
    List<CareRecommendation>? recommendations,
    bool? hasRating,
    int? myRating,
    String? status,
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
    );
  }

  factory CareHistory.fromJson(Map<String, dynamic> json) {
    return CareHistory(
      id: json['id'] as int,
      createdAt: json['createdAt'] as int,
      query: json['query'] as String,
      keyword: json['keyword'] as String,
      status: json['status'] as String,
      hasRating: json['hasRating'] as bool,
      myRating: json['myRating'] as int?,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => CareRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      reason: json['reason'] as String?,
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
      id: json['id'] as int,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productPrice: json['productPrice'] as int,
      productLink: json['productLink'] as String,
      productImage: json['productImage'] as String,
      productDescription: json['productDescription'] as String?,
      source: json['source'] as String,
      mallName: json['mallName'] as String,
      keyword: json['keyword'] as String,
      reviewCount: json['reviewCount'] as int,
      liked: json['liked'] as bool,
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