import 'package:alfred_clean/features/call/model/product.dart';

class LikedProduct {
  final int historyId;
  final String recommendId;
  final String productId;
  final String mallName;
  final String productName;
  final int productPrice;
  final String productLink;
  final String productImage;
  final String reason;
  final String source;
  final String category;
  final String historyAddedAt;
  final DateTime likedAt;

  LikedProduct({
    required this.historyId,
    required this.recommendId,
    required this.productId,
    required this.mallName,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    required this.productImage,
    required this.reason,
    required this.source,
    required this.category,
    required this.historyAddedAt,
    required this.likedAt,
  });

  factory LikedProduct.fromJson(Map<String, dynamic> json) {
    return LikedProduct(
      historyId:      json['historyId'],
      recommendId:      json['recommendId'] as String,
      productId:        json['productId'] as String,
      mallName:         json['mallName'] as String,
      productName:      json['productName'] as String,
      productPrice:     json['productPrice'] as int,
      productLink:      json['productLink'] as String,
      productImage:     json['productImage'] as String,
      reason:           json['reason'] as String,
      source:           json['source'] as String,
      category:         json['category'] as String,
      historyAddedAt:   json['historyAddedAt'] as String,
      likedAt:          DateTime.parse(json['likedAt'] as String),
    );
  }

  Product toProduct() {
    return Product(
      recommendationId: recommendId,
      name: productName,
      productId: productId,
      price: productPrice,
      image: productImage,
      link: productLink,
      reason: reason,
      mallName: mallName,
      category: category,
      liked: true,
      reviewCount: 0,
      source: source,
    );
  }
}