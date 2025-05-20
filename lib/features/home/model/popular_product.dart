class PopularProduct {
  final String userId;
  final int productId;
  final String mallName;
  final int cnt;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String reason;
  final String source;
  final String category;
  final String historyAddedAt;

  PopularProduct({
    required this.userId,
    required this.productId,
    required this.mallName,
    required this.cnt,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.reason,
    required this.source,
    required this.category,
    required this.historyAddedAt,
  });

  factory PopularProduct.fromJson(Map<String, dynamic> json) {
    return PopularProduct(
      userId: json['userId'] as String,
      productId: json['productId'],
      mallName: json['mallName'],
      cnt: json['cnt'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      productLink: json['productLink'],
      productImage: json['productImage'],
      reason: json['reason'],
      source: json['source'],
      category: json['category'],
      historyAddedAt: json['historyAddedAt'] as String? ?? '',
    );
  }
}