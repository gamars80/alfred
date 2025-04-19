

import '../../call/model/product.dart';

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

  RecommendationHistory copyWith({
    List<Product>? recommendations,
  }) {
    return RecommendationHistory(
      id: id,
      userId: userId,
      createdAt: createdAt,
      query: query,
      gptCondition: gptCondition,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      id: json['id'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      query: json['query'],
      gptCondition: json['gptCondition'],
      recommendations: (json['recommendations'] as List)
          .map((e) => Product.fromHistoryJson(e))
          .toList(),
    );
  }
}