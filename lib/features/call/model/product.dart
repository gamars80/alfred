class Product {
  final String recommendationId;
  final String name;
  final String productId;
  final int price;
  final String image;
  final String link;
  final String reason;
  final String mallName;
  final String category;
  final bool liked;
  final int reviewCount;
  final String? source;

  Product({
    required this.recommendationId,
    required this.name,
    required this.productId,
    required this.price,
    required this.image,
    required this.link,
    required this.reason,
    required this.mallName,
    required this.category,
    required this.liked,
    required this.reviewCount,
    required this.source,
  });

  Product copyWith({
    bool? liked,
  }) {
    return Product(
      recommendationId: recommendationId,
      name: name,
      productId: productId,
      price: price,
      image: image,
      link: link,
      reason: reason,
      mallName: mallName,
      category: category,
      reviewCount: reviewCount,
      source: source,
      liked: liked ?? this.liked,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['productName'] ?? json['name'] ?? '',
      price: json['productPrice'] ?? json['price'] ?? 0,
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
      reviewCount: _parseReviewCount(json['reviewCount']),
      liked: json['liked'] as bool? ?? false,
      recommendationId: (json['id'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      image: (json['productImage'] ?? json['image'] ?? '').toString(),
      link: (json['productLink'] ?? json['link'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  factory Product.fromHistoryJson(Map<String, dynamic> json) {
    return Product(
      recommendationId: (json['id'] ?? '').toString(),
      name: json['productName'] ?? '',
      productId: json['productId'] ?? '',
      price: json['productPrice'] ?? 0,
      image: json['productImage'] ?? '',
      link: json['productLink'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] ?? '',
      reviewCount: _parseReviewCount(json['reviewCount']),
      liked: json['liked'] ?? false,
    );
  }

  static int _parseReviewCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}