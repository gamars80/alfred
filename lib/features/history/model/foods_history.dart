class FoodsHistory {
  final int id;
  final int createdAt;
  final String? query;
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

  FoodsHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.ingredients,
    required this.suggested,
    required this.suggestionReason,
    required this.recipeSummary,
    required this.status,
    required this.hasRating,
    required this.myRating,
    required this.requiredIngredients,
    required this.recommendations,
    required this.recipes,
  });

  FoodsHistory copyWith({
    List<FoodsProduct>? recommendations,
    List<FoodsRecipe>? recipes,
    bool? hasRating,
    int? myRating,
    String? status,
  }) {
    return FoodsHistory(
      id: id,
      createdAt: createdAt,
      query: query,
      ingredients: ingredients,
      suggested: suggested,
      suggestionReason: suggestionReason,
      recipeSummary: recipeSummary,
      requiredIngredients: requiredIngredients,
      recommendations: recommendations ?? this.recommendations,
      recipes: recipes ?? this.recipes,
      hasRating: hasRating ?? this.hasRating,
      myRating: myRating ?? this.myRating,
      status: status ?? this.status,
    );
  }

  factory FoodsHistory.fromJson(Map<String, dynamic> json) {
    return FoodsHistory(
      id: json['id'],
      createdAt: json['createdAt'],
      query: json['query'],
      ingredients: json['ingredients'],
      suggested: json['suggested'],
      suggestionReason: json['suggestionReason'],
      recipeSummary: json['recipeSummary'],
      status: json['status'],
      hasRating: json['hasRating'],
      myRating: json['myRating'],
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
      productId: json['productId'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      productLink: json['productLink'],
      productImage: json['productImage'],
      productDescription: json['productDescription'],
      source: json['source'],
      mallName: json['mallName'],
      category: json['category'],
      reviewCount: json['reviewCount'],
      liked: json['liked'],
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
      recipeName: json['recipeName'],
      detailLink: json['detailLink'],
      recipeImage: json['recipeImage'],
      averageRating: json['averageRating'],
      reviewCount: json['reviewCount'],
      viewCount: json['viewCount'],
      liked: json['liked'],
    );
  }
} 