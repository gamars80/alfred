import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/common/dio/dio_client.dart';
import '../model/food_recommendation.dart';
import '../data/product_api.dart';  // Import ChoiceTypeException
import '../model/recent_foods_command.dart';

class FoodApi {
  final Dio _dio = DioClient.dio;

  Future<FoodRecommendationResult> fetchFoodRecommendation(String query) async {
    debugPrint('🔍 [fetchFoodRecommendation] query: $query');
    try {
      final response = await _dio.post(
        '/api/ai-search/foods',
        data: {'query': query},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final data = response.data as Map<String, dynamic>;
      return FoodRecommendationResult.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '❌ [DioException] type=${e.type}, message=${e.message}, error=${e.error}',
      );

      final data = e.response?.data;
      // Choice Type 예외 처리 추가
      if (data is Map<String, dynamic> &&
          data['error'] == 'Choice Type' &&
          data['itemTypes'] != null) {
        throw ChoiceTypeException(List<String>.from(data['itemTypes']));
      }

      // DynamoDB 에러 처리
      if (e.response?.statusCode == 500 && 
          data is Map<String, dynamic> && 
          data['message']?.toString().contains('DynamoDb') == true) {
        // DynamoDB 에러지만 Choice Type 응답이 있는 경우
        if (data['itemTypes'] != null) {
          throw ChoiceTypeException(List<String>.from(data['itemTypes']));
        }
        // 일반적인 DynamoDB 에러인 경우
        throw Exception('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      }

      // 기타 메시지 기반 에러
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      
      // 기타 모든 DioException
      throw Exception('네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    } catch (e, stack) {
      debugPrint('❌ [UnknownError] $e\n$stack');
      throw Exception('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 최근 음식 명령 조회 API
  Future<List<RecentFoodsCommand>> fetchRecentFoodsCommands() async {
    try {
      final response = await _dio.get(
        '/api/recomendation-history/recently-recommend-foods-history',
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => RecentFoodsCommand.fromJson(item)).toList();
    } catch (e) {
      debugPrint('❌ [fetchRecentFoodsCommands] Error: $e');
      rethrow;
    }
  }

  /// 상품 오픈 기록 API
  Future<void> openFood(String productId, String historyId, String source) async {
    try {
      await _dio.post(
        '/api/products/productId/historyId/source/openFood'
          .replaceFirst('productId', productId)
          .replaceFirst('historyId', historyId)
          .replaceFirst('source', source),
      );
    } catch (e) {
      debugPrint('❌ [openFood] Error: $e');
      // 실패해도 예외를 던지지 않음
    }
  }

  /// 레시피 오픈 기록 API
  Future<void> openRecipe(String historyId, String recipeId) async {
    try {
      await _dio.post(
        '/api/products/$historyId/$recipeId/openRecipe',
      );
    } catch (e) {
      debugPrint('❌ [openRecipe] Error: $e');
      // 실패해도 예외를 던지지 않음
    }
  }
} 