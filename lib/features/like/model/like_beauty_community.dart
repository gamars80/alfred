class LikedBeautyCommunity {
  final int beautyCommunityId;
  final String source;
  final String content;
  final List<String>? photoUrls; // ⬅ null 허용
  final String historyAddedAt;
  final DateTime likedAt;

  LikedBeautyCommunity({
    required this.beautyCommunityId,
    required this.source,
    required this.content,
    required this.photoUrls,
    required this.historyAddedAt,
    required this.likedAt,
  });

  factory LikedBeautyCommunity.fromJson(Map<String, dynamic> json) {
    return LikedBeautyCommunity(
      beautyCommunityId: json['beautyCommunityId'] as int,
      source: json['source'] as String,
      content: json['content'] as String,
      photoUrls: (json['photoUrls'] as List?)?.map((e) => e.toString()).toList(), // ⬅ null-safe 변환
      historyAddedAt: json['historyAddedAt'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}
