import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/youtube_video.dart';

/// 시술 커뮤니티 + 유튜브 영상 결과를 담는 DTO
class BeautyResult {
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;
  BeautyResult({required this.communityPosts, required this.events, required this.hospitals, required this.youtubeVideos});
}


class BeautyApi {
  final Dio _dio = DioClient.dio;

  Future<BeautyResult> fetchBeautyData(String query) async {
    try {
      final response = await _dio.post(
        '/api/ai-search/beauty',
        data: {'query': query},
      );
      final data = response.data as Map<String, dynamic>;
      final postsJson = data['communityPosts'] as List<dynamic>;
      final eventsJson = data['events'] as List<dynamic>;
      final hospitalJson = data['hospitals'] as List<dynamic>;
      final videosJson = data['youtubeVideos'] as List<dynamic>;

      final posts = postsJson
          .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList();

      final events = eventsJson
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

      final hospitals = hospitalJson
          .map((e) => Hospital.fromJson(e as Map<String, dynamic>))
          .toList();

      final videos = videosJson
          .map((e) => YouTubeVideo.fromJson(e as Map<String, dynamic>))
          .toList();

      return BeautyResult(communityPosts: posts, events: events, hospitals: hospitals, youtubeVideos: videos);

    } on DioException catch (e) {
      final serverData = e.response?.data;
      if (serverData is Map<String, dynamic> && serverData['message'] != null) {
        throw Exception(serverData['message']);
      }
      rethrow;
    }
  }
}
