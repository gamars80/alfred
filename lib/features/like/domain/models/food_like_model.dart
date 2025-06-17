class FoodLikeModel {
  final int id;
  final int userId;
  final int historyId;
  final String recommendId;
  final String productId;
  final String mallName;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String productDescription;
  final String source;
  final String category;
  final DateTime likedAt;

  FoodLikeModel({
    required this.id,
    required this.userId,
    required this.historyId,
    required this.recommendId,
    required this.productId,
    required this.mallName,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.productDescription,
    required this.source,
    required this.category,
    required this.likedAt,
  });

  factory FoodLikeModel.fromJson(Map<String, dynamic> json) {
    return FoodLikeModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      historyId: json['historyId'] as int,
      recommendId: json['recommendId'] as String,
      productId: json['productId'] as String,
      mallName: json['mallName'] as String,
      productName: json['productName'] as String,
      productPrice: json['productPrice'] as int,
      productLink: json['productLink'] as String,
      productImage: json['productImage'] as String,
      productDescription: json['productDescription'] as String,
      source: json['source'] as String,
      category: json['category'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
} 