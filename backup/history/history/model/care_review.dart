class CareReview {
  final int id;
  final int reviewId;
  final String content;
  final String productName;
  final String brandName;
  final int likeCount;
  final int viewCount;
  final int createdAt;
  final String thumbnailImageUrl;
  final String keyword;
  final String source;
  final String mallName;

  CareReview({
    required this.id,
    required this.reviewId,
    required this.content,
    required this.productName,
    required this.brandName,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    required this.thumbnailImageUrl,
    required this.keyword,
    required this.source,
    required this.mallName,
  });

  factory CareReview.fromJson(Map<String, dynamic> json) {
    return CareReview(
      id: json['id'] as int,
      reviewId: json['reviewId'] as int,
      content: json['content'] as String,
      productName: json['productName'] as String,
      brandName: json['brandName'] as String,
      likeCount: json['likeCount'] as int,
      viewCount: json['viewCount'] as int,
      createdAt: json['createdAt'] as int,
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      keyword: json['keyword'] as String,
      source: json['source'] as String,
      mallName: json['mallName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewId': reviewId,
      'content': content,
      'productName': productName,
      'brandName': brandName,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'createdAt': createdAt,
      'thumbnailImageUrl': thumbnailImageUrl,
      'keyword': keyword,
      'source': source,
      'mallName': mallName,
    };
  }
} 