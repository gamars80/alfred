import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/paginated_liked_products.dart';

class LikeRepository {
  final Dio _dio = DioClient.dio;
  final int pageSize;

  LikeRepository({this.pageSize = 20});

  Future<PaginatedLikedProducts> fetchLikedProducts({int page = 0}) async {
    final response = await _dio.get('/api/likes/me', queryParameters: {
      'page': page,
      'size': pageSize,
    });

    return PaginatedLikedProducts.fromJson(response.data);
  }
}
