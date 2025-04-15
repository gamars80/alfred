class Product {
  final String name;
  final int price;
  final String image;
  final String link;
  final String reason;
  final String mallName; // 🆕 쇼핑몰 이름 추가

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.link,
    required this.reason,
    required this.mallName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '', // 🆕 파싱 추가
    );
  }

  factory Product.fromHistoryJson(Map<String, dynamic> json) {
    return Product(
      name: json['productName'] ?? '',
      price: json['productPrice'] ?? 0,
      image: json['productImage'] ?? '',
      link: json['productLink'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '', // 🆕 파싱 추가
    );
  }
}
