class PopularFoodIngredient {
  final String ingredient;
  final int count;

  PopularFoodIngredient({
    required this.ingredient,
    required this.count,
  });

  factory PopularFoodIngredient.fromJson(Map<String, dynamic> json) {
    return PopularFoodIngredient(
      ingredient: json['ingredient'] as String,
      count: json['count'] as int,
    );
  }
} 