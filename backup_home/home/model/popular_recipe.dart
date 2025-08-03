class PopularRecipe {
  final int? historyId;
  final String? userId;
  final String recipeId;
  final int? count;
  final String recipeName;
  final String detailLink;
  final String recipeImage;
  final double averageRating;
  final int reviewCount;
  final int viewCount;
  final bool? liked;
  final String? createdAt;
  final String? ingredients;
  final String? suggested;
  final String? source;
  final String? primarySearchKeyword;

  PopularRecipe({
    this.historyId,
    this.userId,
    required this.recipeId,
    this.count,
    required this.recipeName,
    required this.detailLink,
    required this.recipeImage,
    required this.averageRating,
    required this.reviewCount,
    required this.viewCount,
    this.liked,
    this.createdAt,
    this.ingredients,
    this.suggested,
    this.source,
    this.primarySearchKeyword,
  });

  // 최적화된 이미지 URL 반환
  String get optimizedImageUrl {
    if (recipeImage.contains('recipe1.ezmember.co.kr')) {
      // 만개레시피 이미지의 경우 더 큰 사이즈 요청
      return recipeImage.replaceAll('_s.jpg', '_m.jpg');
    }
    return recipeImage;
  }

  factory PopularRecipe.fromJson(Map<String, dynamic> json) {
    return PopularRecipe(
      historyId: json['historyId'] as int?,
      userId: json['userId'] as String?,
      recipeId: json['recipeId'] as String,
      count: json['count'] as int?,
      recipeName: json['recipeName'] as String,
      detailLink: json['detailLink'] as String,
      recipeImage: json['recipeImage'] as String,
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      liked: json['liked'] as bool?,
      createdAt: json['createdAt']?.toString(),
      ingredients: json['ingredients'] as String?,
      suggested: json['suggested'] as String?,
      source: json['source'] as String?,
      primarySearchKeyword: json['primarySearchKeyword'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'userId': userId,
      'recipeId': recipeId,
      'count': count,
      'recipeName': recipeName,
      'detailLink': detailLink,
      'recipeImage': recipeImage,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'viewCount': viewCount,
      'liked': liked,
      'createdAt': createdAt,
      'ingredients': ingredients,
      'suggested': suggested,
      'source': source,
      'primarySearchKeyword': primarySearchKeyword,
    };
  }
}

class RecipePageResult {
  final List<PopularRecipe> items;
  final int totalCount;
  final String? nextCursor;

  RecipePageResult({
    required this.items,
    required this.totalCount,
    this.nextCursor,
  });

  factory RecipePageResult.fromJson(Map<String, dynamic> json) {
    return RecipePageResult(
      items: (json['items'] as List)
          .map((e) => PopularRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      nextCursor: json['nextCursor'] as String?,
    );
  }
} 