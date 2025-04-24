import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/product.dart';


class ProductApi {
  final Dio _dio = DioClient.dio;

  Future<Map<String, List<Product>>> fetchRecommendedProducts(String query) async {
    final response = await _dio.post('/api/ai-search', data: {'query': query});
    final jsonMap = response.data['items'] as Map<String, dynamic>;

    return jsonMap.map((category, items) {
      final productList = (items as List).map((e) => Product.fromJson(e)).toList();
      return MapEntry(category, productList);
    });
  }
}