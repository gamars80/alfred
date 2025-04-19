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
      liked: liked ?? this.liked,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      recommendationId: json['id'] as String? ?? '',
      name: json['productName'] ?? json['name'] ?? '',
      productId: json['productId'] ?? '',
      price: json['productPrice'] ?? json['price'] ?? 0,
      image: json['productImage'] ?? json['image'] ?? '',
      link: json['productLink'] ?? json['link'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
      liked: json['liked'] as bool? ?? false,
    );
  }

  factory Product.fromHistoryJson(Map<String, dynamic> json) {
    return Product(
      recommendationId: json['id'] ?? '',
      name: json['productName'] ?? '',
      productId: json['productId'] ?? '',
      price: json['productPrice'] ?? 0,
      image: json['productImage'] ?? '',
      link: json['productLink'] ?? '',
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
      liked: json['liked'] ?? false,
    );
  }
}