import 'foods_history.dart';

class FoodsHistoryResponse {
  final List<FoodsHistory> histories;
  final String? nextPageKey;

  FoodsHistoryResponse({
    required this.histories,
    required this.nextPageKey,
  });

  factory FoodsHistoryResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> historiesJson = json['histories'];
    // 최신순 정렬
    historiesJson.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
    return FoodsHistoryResponse(
      histories: historiesJson
          .map((e) => FoodsHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
} 