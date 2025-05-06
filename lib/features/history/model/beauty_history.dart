import 'package:alfred_clean/features/call/model/hostpital.dart';
import '../../call/model/community_post.dart';
import '../../call/model/event.dart';
import '../../call/model/youtube_video.dart';

class BeautyHistory {
  final String id;
  final String query;
  final String keyword;
  final int createdAt;

  final List<CommunityPost>? _recommendedPostsByGangnam;
  final List<Event>? _recommendedEvents;
  final List<Hospital>? _recommendedHospitals;
  final List<YouTubeVideo>? _recommendedVideos;

  BeautyHistory({
    required this.id,
    required this.query,
    required this.keyword,
    required this.createdAt,
    List<CommunityPost>? recommendedPostsByGangnam,
    List<Event>? recommendedEvents,
    List<Hospital>? recommendedHospitals,
    List<YouTubeVideo>? recommendedVideos,
  })  : _recommendedPostsByGangnam = recommendedPostsByGangnam,
        _recommendedEvents = recommendedEvents,
        _recommendedHospitals = recommendedHospitals,
        _recommendedVideos = recommendedVideos;

  List<CommunityPost> get recommendedPostsByGangnam => _recommendedPostsByGangnam ?? [];
  List<Event> get recommendedEvents => _recommendedEvents ?? [];
  List<Hospital> get recommendedHospitals => _recommendedHospitals ?? [];
  List<YouTubeVideo> get recommendedVideos => _recommendedVideos ?? [];

  factory BeautyHistory.fromJson(Map<String, dynamic> json) {
    print('📦 raw BeautyHistory json: $json'); // 👉 여기 찍혀야 함

    return BeautyHistory(
      id: json['id'] as String,
      query: json['query'] as String,
      keyword: json['keyword'] as String,
      createdAt: json['createdAt'] as int,
      recommendedPostsByGangnam: (json['recommendedPostsByGangnam'] as List?)
          ?.map((e) => CommunityPost.fromJson(e))
          .toList() ?? [],
      recommendedEvents: (json['recommendedEvents'] ?? []).map<Event>((e) => Event.fromJson(e)).toList(),
      recommendedHospitals: (json['recommendedHospitals'] ?? []).map<Hospital>((e) => Hospital.fromJson(e)).toList(),
      recommendedVideos: (json['recommendedVideos'] ?? []).map<YouTubeVideo>((e) => YouTubeVideo.fromJson(e)).toList(),
    );
  }


}

// ✅ ⬇️ BeautyHistory 바깥에 선언할 것
class BeautyHistoryResponse {
  final List<BeautyHistory> histories;
  final String? nextPageKey;

  BeautyHistoryResponse({
    required this.histories,
    this.nextPageKey,
  });

  factory BeautyHistoryResponse.fromJson(Map<String, dynamic> json) {
    print('✅ [BeautyHistoryResponse] raw json: $json'); // 이게 가장 중요!
    final List<dynamic> items = json['histories'] ?? [];
    items.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
    return BeautyHistoryResponse(
      histories: items.map((e) {
        print('✅ [item] $e'); // 각 항목 찍히는지 확인
        return BeautyHistory.fromJson(e as Map<String, dynamic>);
      }).toList(),
      nextPageKey: json['nextPageKey'] as String?,
    );
  }
}