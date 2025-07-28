import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/beauty_recommendation.dart';

class BeautyRecommendationApi {
  final Dio _dio = DioClient.dio;

  /// 성형/시술 추천 API 호출
  Future<BeautyRecommendationResult> fetchBeautyRecommendation(String query) async {
    debugPrint('🔍 [BeautyRecommendationApi] query: $query');
    
    try {
      final response = await _dio.post(
        '/api/ai-search/beauty',
        data: {'query': query},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final data = response.data as Map<String, dynamic>;
      
      // 응답에서 생성 시점 타임스탬프 파싱
      final createdAt = data['createdAt'] as int?;
      if (createdAt == null) {
        throw Exception('API 응답에 "createdAt" 필드가 없습니다');
      }

      // 각 카테고리별 데이터 파싱
      final communityPostsJson = data['communityPosts'] as List<dynamic>? ?? [];
      final eventsJson = data['events'] as List<dynamic>? ?? [];
      final hospitalsJson = data['hospitals'] as List<dynamic>? ?? [];
      final youtubeVideosJson = data['youtubeVideos'] as List<dynamic>? ?? [];

      // 총 검색 결과 수 계산
      final totalCount = communityPostsJson.length + 
                        eventsJson.length + 
                        hospitalsJson.length + 
                        youtubeVideosJson.length;

      debugPrint('📊 [BeautyRecommendationApi] 총 검색 결과: $totalCount건');
      debugPrint('  - 커뮤니티 게시글: ${communityPostsJson.length}건');
      debugPrint('  - 이벤트: ${eventsJson.length}건');
      debugPrint('  - 병원: ${hospitalsJson.length}건');
      debugPrint('  - 유튜브 영상: ${youtubeVideosJson.length}건');

      return BeautyRecommendationResult(
        createdAt: createdAt,
        totalCount: totalCount,
        communityPosts: communityPostsJson,
        events: eventsJson,
        hospitals: hospitalsJson,
        youtubeVideos: youtubeVideosJson,
      );

    } on DioException catch (e) {
      debugPrint('❌ [BeautyRecommendationApi] DioException: ${e.message}');
      debugPrint('🔹 statusCode: ${e.response?.statusCode}');
      debugPrint('🔹 Response Data: ${e.response?.data}');

      final data = e.response?.data;
      
      // 백엔드 커스텀 에러 메시지 파싱
      if (data is Map<String, dynamic> && data['message'] != null) {
        final message = data['message'].toString();
        
        if (message.contains('Already Recommend')) {
          throw Exception('alreadyRecommend');
        } else if (message.contains('Not enough Command')) {
          throw Exception('not_enough_command');
        } else if (message.contains('Not ItemType')) {
          throw Exception('itemType');
        } else if (message.contains('Choice Type')) {
          // Choice Type 에러는 itemTypes가 null이어도 처리
          throw Exception('choiceType');
        } else {
          throw Exception(message);
        }
      }
      
      rethrow;
    } catch (e) {
      debugPrint('❌ [BeautyRecommendationApi] UnknownError: $e');
      rethrow;
    }
  }

  /// 성형/시술 추천 상태 확인 API
  Future<BeautyRecommendationStatus> checkRecommendationStatus(int createdAt) async {
    try {
      final response = await _dio.get(
        '/api/ai-search/beauty/status',
        queryParameters: {'createdAt': createdAt},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as Map<String, dynamic>;
      return BeautyRecommendationStatus.fromJson(data);
    } catch (e) {
      debugPrint('❌ [BeautyRecommendationApi] Status check error: $e');
      rethrow;
    }
  }

  /// 최근 성형/시술 추천 히스토리 조회
  Future<List<BeautyRecommendationHistory>> fetchRecentHistory({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/recomendation-history/beauty-history',
        queryParameters: {'limit': limit},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic> || rawData['histories'] == null) {
        throw Exception('예상치 못한 데이터 형식: ${rawData.runtimeType}');
      }

      final historiesJson = rawData['histories'] as List<dynamic>;
      return historiesJson
          .map((e) => BeautyRecommendationHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ [BeautyRecommendationApi] History fetch error: $e');
      rethrow;
    }
  }
} 