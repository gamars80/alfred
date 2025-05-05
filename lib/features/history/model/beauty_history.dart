import '../../call/model/community_post.dart';
import '../../call/model/event.dart';
import '../../call/model/youtube_video.dart';


class BeautyHistory {
  final String id;
  final String query;
  final String keyword;
  final int createdAt;

  final List<CommunityPost> recommendedPostsByGangnam;
  final List<Event> recommendedEventByGangNam;
  final List<YouTubeVideo> recommendedVideos;

  BeautyHistory({
    required this.id,
    required this.query,
    required this.keyword,
    required this.createdAt,
    this.recommendedPostsByGangnam = const [],
    this.recommendedEventByGangNam = const [],
    this.recommendedVideos = const [],
  });

  factory BeautyHistory.fromJson(Map<String, dynamic> json) {
    return BeautyHistory(
      id: json['id'] as String,
      query: json['query'] as String,
      keyword: json['keyword'] as String,
      createdAt: json['createdAt'] as int,
      recommendedPostsByGangnam:
      (json['recommendedPostsByGangnam'] as List<dynamic>?)
          ?.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      recommendedEventByGangNam:
      (json['recommendedEventByGangNam'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],

      recommendedVideos:
      (json['recommendedVideos'] as List<dynamic>?)
          ?.map((e) => YouTubeVideo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class BeautyHistoryResponse {
  final List<BeautyHistory> histories;
  final String? nextPageKey;

  BeautyHistoryResponse({
    required this.histories,
    this.nextPageKey,
  });

  factory BeautyHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['histories'] as List<dynamic>;
    items.sort((a, b) =>
        (b['createdAt'] as int).compareTo(a['createdAt'] as int));
    return BeautyHistoryResponse(
      histories: items
          .map((e) => BeautyHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
}