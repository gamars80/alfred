import 'package:alfred_clean/features/call/model/product.dart';

class RecommendationHistory {
  final String id;
  final String userId;
  final int createdAt;
  final String query;
  final String gptCondition;
  final List<Product> recommendations;

  RecommendationHistory({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.query,
    required this.gptCondition,
    required this.recommendations,
  });

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] as int,
      query: json['query'] as String,
      gptCondition: json['gptCondition'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Product.fromHistoryJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
