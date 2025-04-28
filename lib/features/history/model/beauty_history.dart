import 'package:flutter/foundation.dart';

/// 시술커뮤니티 히스토리 모델
class BeautyHistory {
  /// 고유 ID
  final String id;

  /// 원본 쿼리(사용자 질문)
  final String query;

  /// GPT가 추출한 키워드
  final String keyword;

  /// 생성 시각 (밀리초)
  final int createdAt;

  BeautyHistory({
    required this.id,
    required this.query,
    required this.keyword,
    required this.createdAt,
  });

  factory BeautyHistory.fromJson(Map<String, dynamic> json) {
    return BeautyHistory(
      id: json['id'] as String,
      query: json['query'] as String,
      keyword: json['keyword'] as String,
      createdAt: json['createdAt'] as int,
    );
  }
}

/// 시술커뮤니티 히스토리 API 응답
class BeautyHistoryResponse {
  /// 히스토리 목록
  final List<BeautyHistory> histories;

  /// 다음 페이지 키 (페이징)
  final String? nextPageKey;

  BeautyHistoryResponse({
    required this.histories,
    this.nextPageKey,
  });

  factory BeautyHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['histories'] as List<dynamic>;
    // 최신순으로 정렬
    items.sort((a, b) =>
        (b['createdAt'] as int).compareTo(a['createdAt'] as int));
    return BeautyHistoryResponse(
      histories: items
          .map((e) => BeautyHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
}
