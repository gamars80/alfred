import '../../call/model/product.dart';

/// 음식/식자재/과일 추천 결과 모델
class FoodRecommendationResult {
  final int createdAt;
  final int totalCount;
  final Map<String, List<Product>> items;
  final List<String> ingredients;
  final String? suggested;
  final bool isSeasonal;
  final String recipeSummary;
  final List<String> requiredIngredients;
  final String? suggestionReason;

  FoodRecommendationResult({
    required this.createdAt,
    required this.totalCount,
    required this.items,
    required this.ingredients,
    this.suggested,
    required this.isSeasonal,
    required this.recipeSummary,
    required this.requiredIngredients,
    this.suggestionReason,
  });

  /// 채팅 응답 메시지 생성
  String generateChatResponse() {
    return '총 $totalCount건의 음식/식자재 정보를 찾았어요! 🍽️✨\n\n추천 결과를 확인해보세요!';
  }

  @override
  String toString() {
    return 'FoodRecommendationResult(createdAt: $createdAt, totalCount: $totalCount)';
  }
}

/// 음식/식자재/과일 추천 상태 모델
class FoodRecommendationStatus {
  final String status;
  final int progress;
  final String? message;

  FoodRecommendationStatus({
    required this.status,
    required this.progress,
    this.message,
  });

  factory FoodRecommendationStatus.fromJson(Map<String, dynamic> json) {
    return FoodRecommendationStatus(
      status: json['status'] as String? ?? 'unknown',
      progress: json['progress'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }
}

/// 음식/식자재/과일 추천 히스토리 모델
class FoodRecommendationHistory {
  final int id;
  final int createdAt;
  final String query;
  final String status;
  final String? ingredients;
  final String? suggested;
  final String? suggestionReason;
  final String? recipeSummary;
  final bool hasRating;
  final int? myRating;
  final List<String> requiredIngredients;

  FoodRecommendationHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.status,
    this.ingredients,
    this.suggested,
    this.suggestionReason,
    this.recipeSummary,
    required this.hasRating,
    this.myRating,
    required this.requiredIngredients,
  });

  factory FoodRecommendationHistory.fromJson(Map<String, dynamic> json) {
    return FoodRecommendationHistory(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      query: json['query'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      ingredients: json['ingredients'] as String?,
      suggested: json['suggested'] as String?,
      suggestionReason: json['suggestionReason'] as String?,
      recipeSummary: json['recipeSummary'] as String?,
      hasRating: json['hasRating'] as bool? ?? false,
      myRating: json['myRating'] as int?,
      requiredIngredients: (json['requiredIngredients'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
} 