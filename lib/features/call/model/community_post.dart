class CommunityPost {
  final int id;
  final String nickname;
  final String content;
  final int viewCount;
  final int commentCount;
  final int thumbUpCount;
  final List<String> photoUrls;
  final bool liked;
  final String source;

  CommunityPost({
    required this.id,
    required this.nickname,
    required this.content,
    required this.viewCount,
    required this.commentCount,
    required this.thumbUpCount,
    required this.photoUrls,
    required this.liked,
    required this.source,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      nickname: json['nickname'],
      content: json['content'],
      viewCount: json['viewCount'],
      commentCount: json['commentCount'],
      thumbUpCount: json['thumbUpCount'],
      source: json['source'],
      liked: json['liked'],
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }
}