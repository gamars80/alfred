import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/common/dio/dio_client.dart';
import '../../call/model/product.dart';
import '../model/beauty_care_recommendation.dart';

class BeautyCareRecommendationApi {
  final Dio _dio = DioClient.dio;

  /// 뷰티케어 추천 API 호출
  Future<BeautyCareRecommendationResult> fetchBeautyCareRecommendation(String query) async {
    debugPrint('🔍 [BeautyCareRecommendationApi] query: $query');
    
    try {
      final response = await _dio.post(
        '/api/ai-search/care',
        data: {'query': query},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final data = response.data as Map<String, dynamic>;
      
      // 응답에서 생성 시점 타임스탬프 파싱
      final createdAt = data['createdAt'] as int?;
      if (createdAt == null) {
        throw Exception('API 응답에 "createdAt" 필드가 없습니다');
      }

      // 추천 이유 파싱
      final reason = data['reason'] as String?;

      // 상품 목록 파싱
      final rawItems = data['items'];
      if (rawItems == null) {
        throw Exception('API 응답에 "items" 필드가 없습니다');
      }

      final itemsMap = (rawItems as Map<String, dynamic>).map((
        category,
        itemsJson,
      ) {
        debugPrint(
          '📂 category="$category", count=${(itemsJson as List).length}',
        );
        final products = (itemsJson as List).map((e) {
          try {
            return Product.fromJson(e as Map<String, dynamic>);
          } catch (err, stack) {
            debugPrint('⚠️ Product.fromJson 실패: $err\n데이터: $e\n$stack');
            rethrow;
          }
        }).toList();
        return MapEntry(category, products);
      });

      // 총 검색 결과 수 계산
      int totalCount = 0;
      itemsMap.forEach((category, products) {
        totalCount += products.length;
      });

      debugPrint('📊 [BeautyCareRecommendationApi] 총 검색 결과: $totalCount건');

      return BeautyCareRecommendationResult(
        createdAt: createdAt,
        totalCount: totalCount,
        items: itemsMap,
        reason: reason,
      );

    } on DioException catch (e) {
      debugPrint('❌ [BeautyCareRecommendationApi] DioException: ${e.message}');
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
      debugPrint('❌ [BeautyCareRecommendationApi] UnknownError: $e');
      rethrow;
    }
  }

  /// 뷰티케어 추천 상태 확인 API
  Future<BeautyCareRecommendationStatus> checkRecommendationStatus(int createdAt) async {
    try {
      final response = await _dio.get(
        '/api/ai-search/care/status',
        queryParameters: {'createdAt': createdAt},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as Map<String, dynamic>;
      return BeautyCareRecommendationStatus.fromJson(data);
    } catch (e) {
      debugPrint('❌ [BeautyCareRecommendationApi] Status check error: $e');
      rethrow;
    }
  }

  /// 최근 뷰티케어 추천 히스토리 조회
  Future<List<BeautyCareRecommendationHistory>> fetchRecentHistory({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/recomendation-history/recently-recommend-care-history',
        queryParameters: {'limit': limit},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final rawData = response.data;
      if (rawData is! List<dynamic>) {
        throw Exception('예상치 못한 데이터 형식: ${rawData.runtimeType}');
      }

      return rawData
          .map((e) => BeautyCareRecommendationHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ [BeautyCareRecommendationApi] History fetch error: $e');
      rethrow;
    }
  }
} 