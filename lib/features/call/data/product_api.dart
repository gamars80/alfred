import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/product.dart';

class ProductApi {
  final Dio _dio = DioClient.dio;

  Future<Map<String, List<Product>>> fetchRecommendedProducts(String query) async {
    debugPrint('🔍 [fetchRecommendedProducts] query: $query');
    try {
      final response = await _dio.post(
        '/api/ai-search',
        data: {'query': query},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final rawItems = response.data['items'];
      if (rawItems == null) {
        throw Exception('API 응답에 "items" 필드가 없습니다');
      }

      final itemsMap = rawItems as Map<String, dynamic>;
      return itemsMap.map((category, itemsJson) {
        debugPrint('📂 category="$category", count=${(itemsJson as List).length}');
        final products = (itemsJson as List).map((e) {
          try {
            return Product.fromJson(e);
          } catch (err, stack) {
            debugPrint('⚠️ Product.fromJson 실패: $err\n데이터: $e\n$stack');
            rethrow;
          }
        }).toList();
        return MapEntry(category, products);
      });
    } on DioException catch (e) {
      debugPrint('❌ [DioException] type=${e.type}, message=${e.message}, error=${e.error}');
      debugPrint('   response: ${e.response}'); // null 일 겁니다.
      // 기존 처리 유지
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