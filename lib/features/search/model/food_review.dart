class FoodReview {
  final String mallProductId;
  final String reviewId;
  final String keyword;
  final String source;
  final String mallName;
  final int rating;
  final String content;
  final List<String> imageUrls;
  final String productName;
  final String productId;
  final int createdAt;
  final FoodRecommendationItem recommendationFoodsItem;

  FoodReview({
    required this.mallProductId,
    required this.reviewId,
    required this.keyword,
    required this.source,
    required this.mallName,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.productName,
    required this.productId,
    required this.createdAt,
    required this.recommendationFoodsItem,
  });

  factory FoodReview.fromJson(Map<String, dynamic> json) {
    return FoodReview(
      mallProductId: json['mallProductId'] as String,
      reviewId: json['reviewId'] as String,
      keyword: json['keyword'] as String,
      source: json['source'] as String,
      mallName: json['mallName'] as String,
      rating: json['rating'] as int,
      content: json['content'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>).cast<String>(),
      productName: json['productName'] as String,
      productId: json['productId'] as String,
      createdAt: json['createdAt'] as int,
      recommendationFoodsItem: FoodRecommendationItem.fromJson(
        json['recommendationFoodsItem'] as Map<String, dynamic>,
      ),
    );
  }
}

class FoodRecommendationItem {
  final String mallProductId;
  final String productId;
  final String productName;
  final String productDescription;
  final String link;
  final String image;
  final String mallName;
  final String keyword;
  final String source;
  final int createdAt;
  final int price;
  final int reviewCount;

  FoodRecommendationItem({
    required this.mallProductId,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.link,
    required this.image,
    required this.mallName,
    required this.keyword,
    required this.source,
    required this.createdAt,
    required this.price,
    required this.reviewCount,
  });

  factory FoodRecommendationItem.fromJson(Map<String, dynamic> json) {
    return FoodRecommendationItem(
      mallProductId: json['mallProductId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productDescription: json['productDescription'] as String,
      link: json['link'] as String,
      image: json['image'] as String,
      mallName: json['mallName'] as String,
      keyword: json['keyword'] as String,
      source: json['source'] as String,
      createdAt: json['createdAt'] as int,
      price: json['price'] as int,
      reviewCount: json['reviewCount'] as int,
    );
  }
}

class FoodReviewPageResult {
  final List<FoodReview> items;
  final String? nextCursor;
  final int totalCount;

  FoodReviewPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  factory FoodReviewPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => FoodReview.fromJson(item as Map<String, dynamic>))
        .toList();
    return FoodReviewPageResult(
      items: items,
      nextCursor: json['nextCursor'] as String?,
      totalCount: (json['totalCount'] as num).toInt(),
    );
  }
} 