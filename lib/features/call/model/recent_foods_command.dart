class RecentFoodsCommand {
  final int id;
  final int createdAt;
  final String query;
  final String? ingredients;
  final String? suggested;
  final String? suggestionReason;
  final String? recipeSummary;
  final String status;
  final bool hasRating;
  final int? myRating;
  final List<String> requiredIngredients;
  final List<FoodsProduct> recommendations;
  final List<FoodsRecipe> recipes;

  RecentFoodsCommand({
    required this.id,
    required this.createdAt,
    required this.query,
    this.ingredients,
    this.suggested,
    this.suggestionReason,
    this.recipeSummary,
    required this.status,
    required this.hasRating,
    this.myRating,
    required this.requiredIngredients,
    required this.recommendations,
    required this.recipes,
  });

  factory RecentFoodsCommand.fromJson(Map<String, dynamic> json) {
    return RecentFoodsCommand(
      id: json['id'] as int,
      createdAt: json['createdAt'] as int,
      query: json['query'] as String,
      ingredients: json['ingredients'] as String?,
      suggested: json['suggested'] as String?,
      suggestionReason: json['suggestionReason'] as String?,
      recipeSummary: json['recipeSummary'] as String?,
      status: json['status'] as String,
      hasRating: json['hasRating'] as bool,
      myRating: json['myRating'] as int?,
      requiredIngredients: (json['requiredIngredients'] as List).map((e) => e as String).toList(),
      recommendations: (json['recommendations'] as List)
          .map((e) => FoodsProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      recipes: (json['recipes'] as List)
          .map((e) => FoodsRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FoodsProduct {
  final int? id;
  final String productId;
  final String productName;
  final int productPrice;
  final String productLink;
  final String? productImage;
  final String? productDescription;
  final String source;
  final String mallName;
  final String category;
  final int reviewCount;
  final bool liked;

  FoodsProduct({
    this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productLink,
    this.productImage,
    this.productDescription,
    required this.source,
    required this.mallName,
    required this.category,
    required this.reviewCount,
    required this.liked,
  });

  factory FoodsProduct.fromJson(Map<String, dynamic> json) {
    return FoodsProduct(
      id: json['id'],
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productPrice: json['productPrice'] as int,
      productLink: json['productLink'] as String,
      productImage: json['productImage'] as String?,
      productDescription: json['productDescription'] as String?,
      source: json['source'] as String,
      mallName: json['mallName'] as String,
      category: json['category'] as String,
      reviewCount: json['reviewCount'] as int,
      liked: json['liked'] as bool,
    );
  }
}

class FoodsRecipe {
  final int? id;
  final String recipeName;
  final String detailLink;
  final String recipeImage;
  final int averageRating;
  final int reviewCount;
  final int viewCount;
  final bool liked;

  FoodsRecipe({
    this.id,
    required this.recipeName,
    required this.detailLink,
    required this.recipeImage,
    required this.averageRating,
    required this.reviewCount,
    required this.viewCount,
    required this.liked,
  });

  factory FoodsRecipe.fromJson(Map<String, dynamic> json) {
    return FoodsRecipe(
      id: json['id'],
      recipeName: json['recipeName'] as String,
      detailLink: json['detailLink'] as String,
      recipeImage: json['recipeImage'] as String,
      averageRating: json['averageRating'] as int,
      reviewCount: json['reviewCount'] as int,
      viewCount: json['viewCount'] as int,
      liked: json['liked'] as bool,
    );
  }
} 