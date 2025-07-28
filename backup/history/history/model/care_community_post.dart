class CareCommunityPost {
  final int id;
  final String postId;
  final String title;
  final int likes;
  final String createdAt;
  final int views;
  final String image;
  final String keyword;
  final String source;
  final bool liked;

  CareCommunityPost({
    required this.id,
    required this.postId,
    required this.title,
    required this.likes,
    required this.createdAt,
    required this.views,
    required this.image,
    required this.keyword,
    required this.source,
    required this.liked,
  });

  factory CareCommunityPost.fromJson(Map<String, dynamic> json) {
    return CareCommunityPost(
      id: json['id'] as int? ?? 0,
      postId: json['postId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      source: json['source'] as String? ?? '',
      liked: json['liked'] as bool? ?? false,
    );
  }

  CareCommunityPost copyWith({
    int? id,
    String? postId,
    String? title,
    int? likes,
    String? createdAt,
    int? views,
    String? image,
    String? keyword,
    String? source,
    bool? liked,
  }) {
    return CareCommunityPost(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      image: image ?? this.image,
      keyword: keyword ?? this.keyword,
      source: source ?? this.source,
      liked: liked ?? this.liked,
    );
  }
} 