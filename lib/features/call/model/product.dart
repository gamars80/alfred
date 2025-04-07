class Product {
  final String name;
  final int price;
  final String image;
  final String link;
  final String reason;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.link,
    required this.reason,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      image: json['image'],
      link: json['link'],
      reason: json['reason'],
    );
  }
}
