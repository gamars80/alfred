import '../../call/model/product.dart';

/// 뷰티케어 추천 결과 모델
class BeautyCareRecommendationResult {
  final int createdAt;
  final int totalCount;
  final Map<String, List<Product>> items;
  final String? reason;

  BeautyCareRecommendationResult({
    required this.createdAt,
    required this.totalCount,
    required this.items,
    this.reason,
  });

  /// 채팅 응답 메시지 생성
  String generateChatResponse() {
    return '총 $totalCount건의 뷰티케어 정보를 찾았어요! 💄✨\n\n추천 결과를 확인해보세요!';
  }

  @override
  String toString() {
    return 'BeautyCareRecommendationResult(createdAt: $createdAt, totalCount: $totalCount)';
  }
}

/// 뷰티케어 추천 상태 모델
class BeautyCareRecommendationStatus {
  final String status;
  final int progress;
  final String? message;

  BeautyCareRecommendationStatus({
    required this.status,
    required this.progress,
    this.message,
  });

  factory BeautyCareRecommendationStatus.fromJson(Map<String, dynamic> json) {
    return BeautyCareRecommendationStatus(
      status: json['status'] as String? ?? 'unknown',
      progress: json['progress'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }
}

/// 뷰티케어 추천 히스토리 모델
class BeautyCareRecommendationHistory {
  final int id;
  final int createdAt;
  final String query;
  final String status;
  final String? reason;
  final bool hasRating;
  final int? myRating;

  BeautyCareRecommendationHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.status,
    this.reason,
    required this.hasRating,
    this.myRating,
  });

  factory BeautyCareRecommendationHistory.fromJson(Map<String, dynamic> json) {
    return BeautyCareRecommendationHistory(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      query: json['query'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      reason: json['reason'] as String?,
      hasRating: json['hasRating'] as bool? ?? false,
      myRating: json['myRating'] as int?,
    );
  }
} 