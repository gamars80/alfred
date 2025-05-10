import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/youtube_video.dart';

/// 시술 커뮤니티 + 유튜브 영상 결과를 담는 DTO
class BeautyResult {
  final int createdAt;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;
  BeautyResult({required this.createdAt, required this.communityPosts, required this.events, required this.hospitals, required this.youtubeVideos});
}

class BeautyApi {
  final Dio _dio = DioClient.dio;

  Future<BeautyResult> fetchBeautyData(String query) async {
    try {
      debugPrint('▶️ 요청 시작: /api/ai-search/beauty, query="$query"');
      final response = await _dio.post(
        '/api/ai-search/beauty',
        data: {'query': query},
      );

      debugPrint('🔸 response.toString():\n${response.toString()}');

      // 1) HTTP 레벨 로그
      debugPrint('🔹 HTTP ${response.statusCode}');
      debugPrint('🔹 Headers: ${response.headers.map}');

      // 2) 원본 데이터 타입 및 전체 크기
      final rawData = response.data;
      // debugPrint('🔸 rawData.runtimeType = ${rawData.runtimeType}');
      // debugPrint('🔸 rawData = $rawData');

      if (rawData is! Map<String, dynamic>) {
        throw Exception('예상치 못한 데이터 형식: ${rawData.runtimeType}');
      }
      final data = rawData;


      debugPrint('• createdAt: ${data['createdAt']} (type: ${data['createdAt']?.runtimeType})');

      // 4) JSON 리스트로 변환 전 길이 체크
      final postsJson  = data['communityPosts']  as List<dynamic>? ?? [];
      final eventsJson = data['events']          as List<dynamic>? ?? [];
      final hospJson   = data['hospitals']       as List<dynamic>? ?? [];
      final vidsJson   = data['youtubeVideos']   as List<dynamic>? ?? [];
      debugPrint('📄 communityPosts length: ${postsJson.length}');
      debugPrint('🏷  events length: ${eventsJson.length}');
      debugPrint('🏥 hospitals length: ${hospJson.length}');
      debugPrint('📺 youtubeVideos length: ${vidsJson.length}');

      // 5) DTO 변환
      final posts = postsJson.map((e) {
        return CommunityPost.fromJson(e as Map<String, dynamic>);
      }).toList();

      final events = eventsJson.map((e) {
        return Event.fromJson(e as Map<String, dynamic>);
      }).toList();

      final hospitals = hospJson.map((e) {
        return Hospital.fromJson(e as Map<String, dynamic>);
      }).toList();

      final videos = vidsJson.map((e) {
        return YouTubeVideo.fromJson(e as Map<String, dynamic>);
      }).toList();

      final createdAt = data['createdAt'];
      debugPrint('✅ 전체 파싱 완료 (createdAt=$createdAt)');

      return BeautyResult(
        createdAt: createdAt,
        communityPosts: posts,
        events: events,
        hospitals: hospitals,
        youtubeVideos: videos,
      );
    } on DioException catch (e) {
      debugPrint('⚠️ DioException: ${e.message}');
      debugPrint('⚙️ response data: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      rethrow;
    } catch (e, st) {
      debugPrint('❌ 파싱 중 예외 발생: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}

