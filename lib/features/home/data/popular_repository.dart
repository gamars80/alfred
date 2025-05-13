import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/popular_product.dart';

class PopularRepository {
  final Dio _dio = DioClient.dio;

  Future<List<PopularProduct>> fetchPopularProducts() async {
    final response = await _dio.get('/api/popular/product');
    return (response.data as List).map((e) => PopularProduct.fromJson(e)).toList();
  }
}
