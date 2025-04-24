import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/history_response.dart';

class HistoryRepository {
  final Dio _dio = DioClient.dio;

  Future<HistoryResponse> fetchHistories({int limit = 10, String? nextPageKey}) async {
    final queryParams = {
      'limit': limit,
      if (nextPageKey != null) 'nextPageKey': nextPageKey,
    };
    final response = await _dio.get('/api/recomendation-history', queryParameters: queryParams);
    return HistoryResponse.fromJson(response.data);
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
}
