// lib/features/community/model/community_post.dart
class PopularCommunity {
  final int communityId;
  final String source;
  final int cnt;
  final String content;
  final String? keyword;
  final List<String> photoUrls;

  PopularCommunity({
    required this.communityId,
    required this.source,
    required this.cnt,
    required this.content,
    this.keyword,
    required this.photoUrls,
  });

  factory PopularCommunity.fromJson(Map<String, dynamic> json) {
    return PopularCommunity(
      communityId: json['communityId'],
      source: json['source'],
      cnt: json['cnt'],
      content: json['content'],
      keyword: json['keyword'],
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }
}
