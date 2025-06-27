class LikedCareProduct {
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
  final String? productDescription;
  final String source;
  final String category;
  final String likedAt;

  LikedCareProduct({
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
    this.productDescription,
    required this.source,
    required this.category,
    required this.likedAt,
  });

  factory LikedCareProduct.fromJson(Map<String, dynamic> json) {
    return LikedCareProduct(
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
      productDescription: json['productDescription'] as String?,
      source: json['source'] as String,
      category: json['category'] as String,
      likedAt: json['likedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'historyId': historyId,
      'recommendId': recommendId,
      'productId': productId,
      'mallName': mallName,
      'productName': productName,
      'productPrice': productPrice,
      'productLink': productLink,
      'productImage': productImage,
      'productDescription': productDescription,
      'source': source,
      'category': category,
      'likedAt': likedAt,
    };
  }
}

class PaginatedCareLikesResponse {
  final List<LikedCareProduct> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedCareLikesResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedCareLikesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedCareLikesResponse(
      content: (json['content'] as List)
          .map((item) => LikedCareProduct.fromJson(item))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
} 