// lib/features/history/data/history_repository.dart

import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/history_response.dart';
import '../model/beauty_history.dart';

/// 히스토리 전반(쇼핑 + 시술커뮤니티) API 호출용 리포지토리
class HistoryRepository {
  final Dio _dio = DioClient.dio;

  /// 쇼핑 히스토리 조회 (페이징)
  Future<HistoryResponse> fetchHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = {
      'limit': limit,
      if (nextPageKey != null) 'nextPageKey': nextPageKey,
    };
    final response = await _dio.get(
      '/api/recomendation-history',
      queryParameters: queryParams,
    );
    return HistoryResponse.fromJson(response.data);
  }

  /// 히스토리 좋아요 등록
  Future<void> postLike({
    required int historyCreatedAt,
    required String recommendationId,
    required String productId,
    required String mallName,
  }) async {
    await _dio.post(
      '/api/likes',
      data: {
        'historyCreatedAt': '$historyCreatedAt',
        'recommendationId': recommendationId,
        'productId': productId,
        'mallName': mallName,
      },
    );
  }

  /// 히스토리 좋아요 취소
  Future<void> deleteLike({
    required int historyCreatedAt,
    required String recommendationId,
    required String productId,
    required String mallName,
  }) async {
    await _dio.delete(
      '/api/likes',
      data: {
        'historyCreatedAt': '$historyCreatedAt',
        'recommendationId': recommendationId,
        'productId': productId,
        'mallName': mallName,
      },
    );
  }
}

/// 시술커뮤니티 히스토리 전용 API 호출 확장
extension BeautyHistoryApi on HistoryRepository {
  /// 시술커뮤니티 히스토리 조회 (페이징)
  Future<BeautyHistoryResponse> fetchBeautyHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = {
      'limit': limit,
      if (nextPageKey != null) 'nextPageKey': nextPageKey,
    };
    final response = await _dio.get(
      '/api/recomendation-history/beauty-history',
      queryParameters: queryParams,
    );
    return BeautyHistoryResponse.fromJson(response.data);
  }
}
