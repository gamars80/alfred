import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/common/dio/dio_client.dart';
import '../../call/model/product.dart';
import '../model/food_recommendation.dart';

class FoodRecommendationApi {
  final Dio _dio = DioClient.dio;

  /// 음식/식자재/과일 추천 API 호출
  Future<FoodRecommendationResult> fetchFoodRecommendation(String query) async {
    debugPrint('🔍 [FoodRecommendationApi] query: $query');
    
    try {
      final response = await _dio.post(
        '/api/ai-search/foods',
        data: {'query': query},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final data = response.data as Map<String, dynamic>;
      
      // 응답에서 생성 시점 타임스탬프 파싱
      final createdAt = data['createdAt'] as int?;
      if (createdAt == null) {
        throw Exception('API 응답에 "createdAt" 필드가 없습니다');
      }

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

      debugPrint('📊 [FoodRecommendationApi] 총 검색 결과: $totalCount건');

      return FoodRecommendationResult(
        createdAt: createdAt,
        totalCount: totalCount,
        items: itemsMap,
        ingredients: List<String>.from(data['ingredients'] as List? ?? []),
        suggested: data['suggested'] as String?,
        isSeasonal: data['isSeasonal'] as bool? ?? false,
        recipeSummary: data['recipeSummary'] as String? ?? '',
        requiredIngredients: List<String>.from(data['requiredIngredients'] as List? ?? []),
        suggestionReason: data['suggestionReason'] as String?,
      );

    } on DioException catch (e) {
      debugPrint('❌ [FoodRecommendationApi] DioException: ${e.message}');
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
      debugPrint('❌ [FoodRecommendationApi] UnknownError: $e');
      rethrow;
    }
  }

  /// 음식/식자재/과일 추천 상태 확인 API
  Future<FoodRecommendationStatus> checkRecommendationStatus(int createdAt) async {
    try {
      final response = await _dio.get(
        '/api/ai-search/foods/status',
        queryParameters: {'createdAt': createdAt},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as Map<String, dynamic>;
      return FoodRecommendationStatus.fromJson(data);
    } catch (e) {
      debugPrint('❌ [FoodRecommendationApi] Status check error: $e');
      rethrow;
    }
  }

  /// 최근 음식/식자재/과일 추천 히스토리 조회
  Future<List<FoodRecommendationHistory>> fetchRecentHistory({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/recomendation-history/recently-recommend-foods-history',
        queryParameters: {'limit': limit},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final rawData = response.data;
      if (rawData is! List<dynamic>) {
        throw Exception('예상치 못한 데이터 형식: ${rawData.runtimeType}');
      }

      return rawData
          .map((e) => FoodRecommendationHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ [FoodRecommendationApi] History fetch error: $e');
      rethrow;
    }
  }
} 