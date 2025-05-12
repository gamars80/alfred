import 'like_beauty_event.dart';

class PaginatedLikedBeautyEvent {
  final List<LikedBeautyEvent> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedLikedBeautyEvent({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedLikedBeautyEvent.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'] as List<dynamic>;
    return PaginatedLikedBeautyEvent(
      content:
          rawList
              .map((e) => LikedBeautyEvent.fromJson(e as Map<String, dynamic>))
              .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
}
