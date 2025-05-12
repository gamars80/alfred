import 'package:alfred_clean/features/like/model/paginated_liked_beauty_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/paginated_liked_beauty_community.dart';
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
    final payload = {
      'historyCreatedAt': '$historyCreatedAt',
      'recommendationId': recommendationId,
      'productId': productId,
      'mallName': mallName,
    };

    debugPrint('📡 DELETE /api/likes 호출');
    debugPrint('   요청 데이터: $payload');

    try {
      final response = await _dio.delete(
        '/api/likes',
        data: payload,
      );
      debugPrint('✅ 삭제 요청 성공 - 상태 코드: ${response.statusCode}');
      debugPrint('   응답 데이터: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ DioException 발생: ${e.message}');
      debugPrint('   상태 코드: ${e.response?.statusCode}');
      debugPrint('   응답 데이터: ${e.response?.data}');
      rethrow;
    } catch (e, st) {
      debugPrint('❌ 일반 예외 발생: $e');
      debugPrint('$st');
      rethrow;
    }
  }


  Future<PaginatedLikedBeautyCommunity> fetchLikedBeautyCommunity({int page = 0}) async {
    final response = await _dio.get('/api/likes/me/beauty-community', queryParameters: {
      'page': page,
      'size': pageSize,
    });

    return PaginatedLikedBeautyCommunity.fromJson(response.data);
  }


  Future<void> postLikeBeautyCommunity({
    required int historyCreatedAt,
    required String beautyCommunityId,
    required String source,
  }) async {
    // 1) 호출 파라미터 전체 로그
      debugPrint('▶️ historyCreatedAt: ${historyCreatedAt.toString()}');
      debugPrint('▶️ beautyCommunityId: $beautyCommunityId');
      debugPrint('▶️ source: $source');

    try {
      // 2) 요청 payload 로그
      final payload = {
        'historyCreatedAt': historyCreatedAt.toString(),
        'beautyCommunityId': beautyCommunityId,
        'source': source,
      };
      debugPrint('   요청 페이로드: $payload');

      // 3) 실제 API 호출
      final response = await _dio.post(
        '/api/likes/beauty-community',
        data: payload,
      );

      // 4) 응답 로그
      debugPrint('✅ API 응답 상태: ${response.statusCode}');
      debugPrint('   응답 데이터: ${response.data}');
    } on DioException catch (e) {
      // 5) 네트워크/서버 에러 로그
      debugPrint('⚠️ DioException 발생: ${e.message}');
      debugPrint('   response.data: ${e.response?.data}');
      rethrow;
    } catch (e, st) {
      // 6) 기타 예외
      debugPrint('❌ 알 수 없는 예외: $e');
      debugPrint('$st');
      rethrow;
    }
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

  Future<void> postLikeBeautyEvent({
    required int historyCreatedAt,
    required String eventId,
    required String source,
  }) async {
    // 1) 호출 파라미터 전체 로그
    debugPrint('▶️ historyCreatedAt: ${historyCreatedAt.toString()}');
    debugPrint('▶️ eventId: $eventId');
    debugPrint('▶️ source: $source');

    try {
      // 2) 요청 payload 로그
      final payload = {
        'historyCreatedAt': historyCreatedAt.toString(),
        'eventId': eventId,
        'source': source,
      };
      debugPrint('   요청 페이로드: $payload');

      // 3) 실제 API 호출
      final response = await _dio.post(
        '/api/likes/beauty-event',
        data: payload,
      );

      // 4) 응답 로그
      debugPrint('✅ API 응답 상태: ${response.statusCode}');
      debugPrint('   응답 데이터: ${response.data}');
    } on DioException catch (e) {
      // 5) 네트워크/서버 에러 로그
      debugPrint('⚠️ DioException 발생: ${e.message}');
      debugPrint('   response.data: ${e.response?.data}');
      rethrow;
    } catch (e, st) {
      // 6) 기타 예외
      debugPrint('❌ 알 수 없는 예외: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<void> deleteLikeBeautyEvent({
    required int historyCreatedAt,
    required String eventId,
    required String source,
  }) async {
    await _dio.delete('/api/likes/beauty-event', data: {
      'historyCreatedAt': '$historyCreatedAt',
      'eventId': eventId,
      'source': source,
    });
  }

  Future<PaginatedLikedBeautyEvent> fetchLikedBeautyEvent({int page = 0}) async {
    final response = await _dio.get('/api/likes/me/beauty-eveny', queryParameters: {
      'page': page,
      'size': pageSize,
    });

    return PaginatedLikedBeautyEvent.fromJson(response.data);
  }

}


