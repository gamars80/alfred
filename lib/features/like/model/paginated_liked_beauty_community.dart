import 'like_beauty_community.dart';

class PaginatedLikedBeautyCommunity {
  final List<LikedBeautyCommunity> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedLikedBeautyCommunity({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedLikedBeautyCommunity.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'] as List<dynamic>;
    return PaginatedLikedBeautyCommunity(
      content:
          rawList
              .map(
                (e) => LikedBeautyCommunity.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
}
