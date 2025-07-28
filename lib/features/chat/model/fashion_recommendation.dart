/// 패션 추천 관련 모델들
/// 
/// 채팅 모드에서 패션 추천 기능에 필요한 모든 데이터 모델을 정의합니다.

/// 패션 추천 결과 모델
class FashionRecommendationResult {
  final int id;
  final int createdAt;
  final Map<String, List<FashionProduct>> items;
  final int totalCount;
  final String status; // processing, completed, error

  FashionRecommendationResult({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.totalCount,
    required this.status,
  });

  /// 상태 메시지 생성
  String getStatusMessage() {
    switch (status) {
      case 'processing':
        return '처리중 (계속 추천중)';
      case 'completed':
        return '완료 (모든 추천완료)';
      case 'error':
        return '오류 발생';
      default:
        return '알 수 없는 상태';
    }
  }

  /// 채팅 메시지용 응답 생성
  String generateChatResponse() {
    return '총 $totalCount건의 패션 상품을 찾았어요! 👗✨\n\n'
           '추천 결과를 확인해보세요!';
  }
}

/// 패션 상품 모델
class FashionProduct {
  final String recommendationId;
  final String name;
  final String productId;
  final int price;
  final String image;
  final String link;
  final String reason;
  final String mallName;
  final String category;
  final bool liked;
  final int reviewCount;
  final String? source;
  final String? productDescription;

  FashionProduct({
    required this.recommendationId,
    required this.name,
    required this.productId,
    required this.price,
    required this.image,
    required this.link,
    required this.reason,
    required this.mallName,
    required this.category,
    required this.liked,
    required this.reviewCount,
    required this.source,
    this.productDescription,
  });

  factory FashionProduct.fromJson(Map<String, dynamic> json) {
    return FashionProduct(
      name: json['productName'] ?? json['name'] ?? '',
      price: json['productPrice'] ?? json['price'] ?? 0,
      reason: json['reason'] ?? '',
      mallName: json['mallName'] ?? '',
      category: json['category'] ?? '',
      reviewCount: _parseReviewCount(json['reviewCount']),
      liked: json['liked'] as bool? ?? false,
      recommendationId: (json['id'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      image: (json['productImage'] ?? json['image'] ?? '').toString(),
      link: (json['productLink'] ?? json['link'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      productDescription: json['productDescription'] ?? '',
    );
  }

  static int _parseReviewCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// 추천 상태 모델
class FashionRecommendationStatus {
  final String status; // processing, completed, error
  final int progress;
  final int total;

  const FashionRecommendationStatus({
    required this.status,
    required this.progress,
    required this.total,
  });

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing';
  bool get hasError => status == 'error';
}

/// 패션 추천 히스토리 모델
class FashionRecommendationHistory {
  final int id;
  final int createdAt;
  final String query;
  final String status;
  final int totalCount;

  FashionRecommendationHistory({
    required this.id,
    required this.createdAt,
    required this.query,
    required this.status,
    required this.totalCount,
  });

  factory FashionRecommendationHistory.fromJson(Map<String, dynamic> json) {
    return FashionRecommendationHistory(
      id: json['id'] as int,
      createdAt: json['createdAt'] as int,
      query: json['query'] as String,
      status: json['status'] as String? ?? 'unknown',
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

/// Choice Type 예외 클래스
class FashionChoiceTypeException implements Exception {
  final List<String> itemTypes;

  FashionChoiceTypeException(this.itemTypes);
} 