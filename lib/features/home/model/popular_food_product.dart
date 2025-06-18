class PopularFoodProduct {
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
  final String category;
  final String ingredients;
  final dynamic suggested;
  final int reviewCount;

  PopularFoodProduct({
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
    required this.category,
    required this.ingredients,
    this.suggested,
    required this.reviewCount,
  });

  factory PopularFoodProduct.fromJson(Map<String, dynamic> json) {
    return PopularFoodProduct(
      historyId: json['historyId'] as int,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      mallName: json['mallName'] as String,
      count: json['count'] as int,
      productName: json['productName'] as String,
      productPrice: json['productPrice'] as int,
      productLink: json['productLink'] as String,
      productImage: json['productImage'] as String,
      productDescription: json['productDescription'] as String,
      source: json['source'] as String,
      category: json['category'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      suggested: json['suggested'],
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }
} 