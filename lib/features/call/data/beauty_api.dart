import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/community_post.dart';
import '../model/youtube_video.dart';

/// 시술 커뮤니티 + 유튜브 영상 결과를 담는 DTO
class BeautyResult {
  final List<CommunityPost> communityPosts;
  final List<YouTubeVideo> youtubeVideos;
  BeautyResult({required this.communityPosts, required this.youtubeVideos});
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
      final videosJson = data['youtubeVideos'] as List<dynamic>;

      final posts = postsJson
          .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList();
      final videos = videosJson
          .map((e) => YouTubeVideo.fromJson(e as Map<String, dynamic>))
          .toList();

      return BeautyResult(communityPosts: posts, youtubeVideos: videos);

    } on DioException catch (e) {
      final serverData = e.response?.data;
      if (serverData is Map<String, dynamic> && serverData['message'] != null) {
        throw Exception(serverData['message']);
      }
      rethrow;
    }
  }
}
