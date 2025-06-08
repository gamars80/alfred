import '../model/product.dart';

class FoodRecommendationResult {
  final int id;
  final int createdAt;
  final List<String> ingredients;
  final String? suggested;
  final bool isSeasonal;
  final String recipeSummary;
  final List<String> requiredIngredients;
  final Map<String, List<Product>> items;

  FoodRecommendationResult({
    required this.id,
    required this.createdAt,
    required this.ingredients,
    this.suggested,
    required this.isSeasonal,
    required this.recipeSummary,
    required this.requiredIngredients,
    required this.items,
  });

  factory FoodRecommendationResult.fromJson(Map<String, dynamic> json) {
    return FoodRecommendationResult(
      id: json['id'] as int,
      createdAt: json['createdAt'] as int,
      ingredients: List<String>.from(json['ingredients'] as List),
      suggested: json['suggested'] as String?,
      isSeasonal: json['isSeasonal'] as bool,
      recipeSummary: json['recipeSummary'] as String,
      requiredIngredients: List<String>.from(json['requiredIngredients'] as List),
      items: (json['items'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      ),
    );
  }
}