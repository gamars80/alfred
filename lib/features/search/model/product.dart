class Product {
  final int productId;
  final String mallName;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String source;
  final String category;

  Product({
    required this.productId,
    required this.mallName,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.source,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      mallName: json['mallName'] ?? '',
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productLink: json['productLink'] ?? '',
      productImage: json['productImage'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
