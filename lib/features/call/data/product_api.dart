import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../auth/common/dio/dio_client.dart';
import '../model/product.dart';
import '../service/recommendation_service.dart';

class ChoiceTypeException implements Exception {
  final List<String> itemTypes;

  ChoiceTypeException(this.itemTypes);
}

class ProductApi {
  final Dio _dio = DioClient.dio;

  /// 쇼핑 추천 API 호출 후, `createdAt`과 상품 목록을 함께 반환합니다.
  Future<RecommendedProductsResult> fetchRecommendedProducts(
    String query,
  ) async {
    debugPrint('🔍 [fetchRecommendedProducts] query: $query');
    try {
      final response = await _dio.post(
        '/api/ai-search',
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
        final products =
            (itemsJson as List).map((e) {
              try {
                return Product.fromJson(e as Map<String, dynamic>);
              } catch (err, stack) {
                debugPrint('⚠️ Product.fromJson 실패: $err\n데이터: \$e\n\$stack');
                rethrow;
              }
            }).toList();
        return MapEntry(category, products);
      });

      return RecommendedProductsResult(createdAt: createdAt, items: itemsMap);
    } on DioException catch (e) {
      debugPrint(
        '❌ [DioException] type=${e.type}, message=${e.message}, error=${e.error}',
      );
      debugPrint('   response: ${e.response}');

      final data = e.response?.data;
      // Choice Type 예외 처리
      if (data is Map<String, dynamic> &&
          data['error'] == 'Choice Type' &&
          data['itemTypes'] != null) {
        throw ChoiceTypeException(List<String>.from(data['itemTypes']));
      }
      // 기타 메시지 기반 에러
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [UnknownError] \$e\n\$stack');
      rethrow;
    }
  }
}
