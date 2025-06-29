class PopularCareProduct {
  final int historyId;
  final String userId;
  final String productId;
  final String mallName;
  final int count;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String productDescription;
  final String source;
  final String keyword;
  final int reviewCount;
  final bool liked;

  PopularCareProduct({
    required this.historyId,
    required this.userId,
    required this.productId,
    required this.mallName,
    required this.count,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.productDescription,
    required this.source,
    required this.keyword,
    required this.reviewCount,
    required this.liked,
  });

  factory PopularCareProduct.fromJson(Map<String, dynamic> json) {
    return PopularCareProduct(
      historyId: json['historyId'] ?? 0,
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      mallName: json['mallName'] ?? '',
      count: json['count'] ?? 0,
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productLink: json['productLink'] ?? '',
      productImage: json['productImage'] ?? '',
      productDescription: json['productDescription'] ?? '',
      source: json['source'] ?? '',
      keyword: json['keyword'] ?? '',
      reviewCount: json['reviewCount'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'userId': userId,
      'productId': productId,
      'mallName': mallName,
      'count': count,
      'productName': productName,
      'productPrice': productPrice,
      'productLink': productLink,
      'productImage': productImage,
      'productDescription': productDescription,
      'source': source,
      'keyword': keyword,
      'reviewCount': reviewCount,
      'liked': liked,
    };
  }
} 