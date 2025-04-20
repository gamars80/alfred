class LikedProduct {
  final String productId;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String mallName;
  final String reason;
  final String category;

  LikedProduct({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.mallName,
    required this.reason,
    required this.category,
  });

  factory LikedProduct.fromJson(Map<String, dynamic> json) {
    return LikedProduct(
      productId: json['productId'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      productLink: json['productLink'],
      productImage: json['productImage'],
      mallName: json['mallName'],
      reason: json['reason'],
      category: json['category'],
    );
  }
}
