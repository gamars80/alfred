import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/common/dio/dio_client.dart';
import '../model/food_recommendation.dart';

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
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [UnknownError] $e\n$stack');
      rethrow;
    }
  }
} 