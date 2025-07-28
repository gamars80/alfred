/// 성형/시술 추천 결과 모델
class BeautyRecommendationResult {
  final int createdAt;
  final int totalCount;
  final List<dynamic> communityPosts;
  final List<dynamic> events;
  final List<dynamic> hospitals;
  final List<dynamic> youtubeVideos;

  BeautyRecommendationResult({
    required this.createdAt,
    required this.totalCount,
    required this.communityPosts,
    required this.events,
    required this.hospitals,
    required this.youtubeVideos,
  });

  /// 채팅 응답 메시지 생성
  String generateChatResponse() {
    return '총 $totalCount건의 성형/시술 정보를 찾았어요! 💉✨\n\n추천 결과를 확인해보세요!';
  }

  @override
  String toString() {
    return 'BeautyRecommendationResult(createdAt: $createdAt, totalCount: $totalCount)';
  }
}

/// 성형/시술 추천 상태 모델
class BeautyRecommendationStatus {
  final String status;
  final int progress;
  final String? message;

  BeautyRecommendationStatus({
    required this.status,
    required this.progress,
    this.message,
  });

  factory BeautyRecommendationStatus.fromJson(Map<String, dynamic> json) {
    return BeautyRecommendationStatus(
      status: json['status'] as String? ?? 'unknown',
      progress: json['progress'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }
}

/// 성형/시술 추천 히스토리 모델
class BeautyRecommendationHistory {
  final int id;
  final int createdAt;
  final String query;
  final String status;

  BeautyRecommendationHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.status,
  });

  factory BeautyRecommendationHistory.fromJson(Map<String, dynamic> json) {
    return BeautyRecommendationHistory(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      query: json['query'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
    );
  }
} 