import 'package:alfred_clean/features/history/model/recommendation_history.dart';

class HistoryResponse {
  final List<RecommendationHistory> histories;
  final String? nextPageKey;

  HistoryResponse({
    required this.histories,
    required this.nextPageKey,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> historiesJson = json['histories'];
    // 최신순 정렬
    historiesJson.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
    return HistoryResponse(
      histories: historiesJson
          .map((e) => RecommendationHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
}
