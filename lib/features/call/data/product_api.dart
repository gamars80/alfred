import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/product.dart';

class ProductApi {
  final Dio _dio = DioClient.dio;

  Future<Map<String, List<Product>>> fetchRecommendedProducts(String query) async {
    try {
      final response = await _dio.post('/api/ai-search', data: {'query': query});
      // 정상 응답 처리
      final jsonMap = response.data['items'] as Map<String, dynamic>;
      return jsonMap.map((category, items) {
        final productList = (items as List)
            .map((e) => Product.fromJson(e))
            .toList();
        return MapEntry(category, productList);
      });
    } on DioException catch (e) {
      // 500 에러일 때 서버가 내려준 message 필드를 꺼내서 던져준다
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      // 그 외는 원래 에러 그대로 던지기
      rethrow;
    }
  }
}