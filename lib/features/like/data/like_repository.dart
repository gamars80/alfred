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

  Future<void> postLike({
    required int historyCreatedAt,
    required String recommendationId,
    required String productId,
    required String mallName,
  }) async {
    await _dio.post('/api/likes', data: {
      'historyCreatedAt': '$historyCreatedAt',
      'recommendationId': recommendationId,
      'productId': productId,
      'mallName': mallName,
    });
  }

  Future<void> deleteLike({
    required int historyCreatedAt,
    required String recommendationId,
    required String productId,
    required String mallName,
  }) async {
    await _dio.delete('/api/likes', data: {
      'historyCreatedAt': '$historyCreatedAt',
      'recommendationId': recommendationId,
      'productId': productId,
      'mallName': mallName,
    });
  }

  Future<void> postLikeBeautyCommunity({
    required int historyCreatedAt,
    required String beautyCommunityId,
    required String source,
  }) async {
    await _dio.post('/api/likes/beauty-community', data: {
      'historyCreatedAt': '$historyCreatedAt',
      'beautyCommunityId': beautyCommunityId,
      'source': source,
    });
  }

  Future<void> deleteLikeBeautyCommunity({
    required int historyCreatedAt,
    required String beautyCommunityId,
    required String source,
  }) async {
    await _dio.delete('/api/likes/beauty-community', data: {
      'historyCreatedAt': '$historyCreatedAt',
      'beautyCommunityId': beautyCommunityId,
      'source': source,
    });
  }

}


