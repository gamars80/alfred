import '../../call/model/product.dart';

class RecommendationHistory {
  final int id;

  // final String userId;
  final int createdAt;
  final String query;

  // final String gptCondition;
  final List<Product> recommendations;
  final String gender;
  final String age;
  final String? useCase;
  final String? season;
  final String? itemType;
  final bool hasRating;
  final int? myRating;
  final String status;

  RecommendationHistory({
    required this.id,
    // required this.userId,
    required this.createdAt,
    required this.query,
    // required this.gptCondition,
    required this.recommendations,
    required this.gender,
    required this.age,
    required this.useCase,
    required this.season,
    required this.itemType,
    required this.hasRating,
    required this.myRating,
    required this.status
  });

  RecommendationHistory copyWith({
    List<Product>? recommendations,
    bool? hasRating,
    int? myRating,
    String? status,
  }) {
    return RecommendationHistory(
      id: id,
      // userId: userId,
      createdAt: createdAt,
      query: query,
      gender: gender,
      age: age,
      useCase: useCase,
      season: season,
      itemType: itemType,
      // gptCondition: gptCondition,
      recommendations: recommendations ?? this.recommendations,
      hasRating: hasRating ?? this.hasRating,
      myRating: myRating ?? this.myRating,
      status: status ?? this.status,
    );
  }

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      id: json['id'],
      // userId: json['userId'],
      createdAt: json['createdAt'],
      query: json['query'],
      gender: json['gender'],
      age: json['age'],
      useCase: json['useCase'],
      season: json['season'],
      itemType: json['itemTypes'],
      hasRating: json['hasRating'],
      myRating: json['myRating'],
      status: json['status'],
      // gptCondition: json['gptCondition'],
      recommendations:
          (json['recommendations'] as List)
              .map((e) => Product.fromHistoryJson(e))
              .toList(),
    );
  }
}
