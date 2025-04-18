class Product {
  final String name;
  final String productId;
  final int price;
  final String image;
  final String link;
  final String reason;
  final String mallName; // 🆕 쇼핑몰 이름 추가
  final String category;

  Product({
    required this.name,
    required this.productId,
    required this.price,
    required this.image,
    required this.link,
    required this.reason,
    required this.mallName,
    required this.category
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      productId: json['productId'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
    );
  }

  factory Product.fromHistoryJson(Map<String, dynamic> json) {
    return Product(
      name: json['productName'] ?? '',
      productId: json['productId'] ?? '',
      price: json['productPrice'] ?? 0,
      image: json['productImage'] ?? '',
      link: json['productLink'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
