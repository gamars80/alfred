import '../../call/model/product.dart';

class Review {
  final String id;
  final String? mallName;
  final String? content;
  final List<String> imageUrls;
  final List<String> selectedOptions;
  final String? productName;
  final String? productImageUrl;
  final int? productPrice;
  final String? productLink;

  Review({
    required this.id,
    this.mallName,
    this.content,
    required this.imageUrls,
    required this.selectedOptions,
    this.productName,
    this.productImageUrl,
    this.productPrice,
    this.productLink,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final recommendationItem = json['recommendationItem'] as Map<String, dynamic>?;
    
    return Review(
      id: json['reviewId'] as String,
      mallName: json['mallName'] as String?,
      content: json['content'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      selectedOptions: (json['selectedOptions'] as List<dynamic>?)?.cast<String>() ?? [],
      productName: json['productName'] as String?,
      productImageUrl: recommendationItem?['image'] as String?,
      productPrice: recommendationItem?['price'] as int?,
      productLink: recommendationItem?['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': id,
      'mallName': mallName,
      'content': content,
      'imageUrls': imageUrls,
      'selectedOptions': selectedOptions,
      'productName': productName,
      'recommendationItem': {
        'image': productImageUrl,
        'price': productPrice,
        'link': productLink,
      },
    };
  }
} 