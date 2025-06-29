class CareReview {
  final String id;
  final String? mallName;
  final String? content;
  final List<String> imageUrls;
  final List<String> selectedOptions;
  final String? productName;
  final String? productImageUrl;
  final int? productPrice;
  final String? productLink;
  final String? keyword;
  final String? source;
  final int? rating;
  final int? createdAt;
  final String? productId;
  final String? mallProductId;

  CareReview({
    required this.id,
    this.mallName,
    this.content,
    required this.imageUrls,
    required this.selectedOptions,
    this.productName,
    this.productImageUrl,
    this.productPrice,
    this.productLink,
    this.keyword,
    this.source,
    this.rating,
    this.createdAt,
    this.productId,
    this.mallProductId,
  });

  factory CareReview.fromJson(Map<String, dynamic> json) {
    final recommendationCareItem = json['recommendationCareItem'] as Map<String, dynamic>?;
    
    return CareReview(
      id: json['reviewId'] as String? ?? '',
      mallName: json['mallName'] as String?,
      content: json['content'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      selectedOptions: [], // API 응답에 selectedOptions가 없으므로 빈 배열
      productName: json['productName'] as String?,
      productImageUrl: recommendationCareItem?['productImage'] as String?,
      productPrice: recommendationCareItem?['productPrice'] as int?,
      productLink: recommendationCareItem?['productLink'] as String?,
      keyword: json['keyword'] as String?,
      source: json['source'] as String?,
      rating: json['rating'] as int?,
      createdAt: json['createdAt'] as int?,
      productId: json['productId'] as String?,
      mallProductId: json['mallProductId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': id,
      'mallName': mallName,
      'content': content,
      'imageUrls': imageUrls,
      'selectedOptions': selectedOptions,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'productLink': productLink,
      'keyword': keyword,
      'source': source,
      'rating': rating,
      'createdAt': createdAt,
      'productId': productId,
      'mallProductId': mallProductId,
    };
  }
}

class CareReviewPageResult {
  final List<CareReview> items;
  final String? nextCursor;
  final int totalCount;

  CareReviewPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  factory CareReviewPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => CareReview.fromJson(item as Map<String, dynamic>))
        .toList();
    return CareReviewPageResult(
      items: items,
      nextCursor: json['nextCursor'],
      totalCount: (json['totalCount'] as num).toInt(),
    );
  }
} 