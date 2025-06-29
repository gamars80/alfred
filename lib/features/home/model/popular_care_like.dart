class PopularCareLike {
  final int historyId;
  final String userId;
  final String productId;
  final String mallName;
  final int cnt;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String productDescription;
  final String source;
  final String category;
  final String historyAddedAt;

  PopularCareLike({
    required this.historyId,
    required this.userId,
    required this.productId,
    required this.mallName,
    required this.cnt,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.productDescription,
    required this.source,
    required this.category,
    required this.historyAddedAt,
  });

  factory PopularCareLike.fromJson(Map<String, dynamic> json) {
    return PopularCareLike(
      historyId: json['historyId'] ?? 0,
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      mallName: json['mallName'] ?? '',
      cnt: json['cnt'] ?? 0,
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productLink: json['productLink'] ?? '',
      productImage: json['productImage'] ?? '',
      productDescription: json['productDescription'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] ?? '',
      historyAddedAt: json['historyAddedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'userId': userId,
      'productId': productId,
      'mallName': mallName,
      'cnt': cnt,
      'productName': productName,
      'productPrice': productPrice,
      'productLink': productLink,
      'productImage': productImage,
      'productDescription': productDescription,
      'source': source,
      'category': category,
      'historyAddedAt': historyAddedAt,
    };
  }
} 