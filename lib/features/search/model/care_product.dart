class CareProduct {
  final String userId;
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
  final String historyId;
  final String query;
  final String historyKeyword;
  final int createdAt;

  CareProduct({
    required this.userId,
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
    required this.historyId,
    required this.query,
    required this.historyKeyword,
    required this.createdAt,
  });

  factory CareProduct.fromJson(Map<String, dynamic> json) {
    return CareProduct(
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
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
      historyId: json['historyId'] as String? ?? '',
      query: json['query'] as String? ?? '',
      historyKeyword: json['historyKeyword'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productLink': productLink,
      'productImage': productImage,
      'productDescription': productDescription,
      'source': source,
      'mallName': mallName,
      'keyword': keyword,
      'reviewCount': reviewCount,
      'liked': liked,
      'historyId': historyId,
      'query': query,
      'historyKeyword': historyKeyword,
      'createdAt': createdAt,
    };
  }
}

class CareProductSearchResponse {
  final List<CareProduct> items;
  final int totalCount;
  final String? nextCursor;

  CareProductSearchResponse({
    required this.items,
    required this.totalCount,
    this.nextCursor,
  });

  factory CareProductSearchResponse.fromJson(Map<String, dynamic> json) {
    return CareProductSearchResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => CareProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      nextCursor: json['nextCursor'] as String?,
    );
  }
} 