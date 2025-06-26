import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/history_response.dart';
import '../model/beauty_history.dart';
import '../model/foods_history_response.dart';
import '../model/care_history.dart';

class HistoryRepository {
  final Dio _dio = DioClient.dio;

  Future<HistoryResponse> fetchHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = <String, dynamic>{
      if (nextPageKey != null) 'nextPageKey': nextPageKey,
    };

    final endpoint = '/api/recomendation-history';
    debugPrint('▶️ fetchHistories 요청 시작 → endpoint=$endpoint, params=$queryParams');


    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      debugPrint(
        '✅ fetchHistories 응답 [${response.statusCode}]\n'
            'data=${response.data}',
      );

      return HistoryResponse.fromJson(response.data);
    } on DioException catch (e, stack) {
      debugPrint('❌ fetchHistories DioError 발생 → type=${e.type}, message=${e.message}');
      debugPrint('  RequestOptions: path=${e.requestOptions.path}, '
          'method=${e.requestOptions.method}, '
          'headers=${e.requestOptions.headers}, '
          'data=${e.requestOptions.data}');
      if (e.response != null) {
        debugPrint('  Response [${e.response?.statusCode}]: ${e.response?.data}');
      }
      debugPrint('  StackTrace:\n$stack');
      rethrow;  // 필요시 사용자에게 다시 던지거나, null 리턴/커스텀 에러로 래핑
    } catch (e, stack) {
      debugPrint('❌ fetchHistories 알 수 없는 에러 발생 → $e');
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    }
  }

  Future<void> postRating({
    required int historyId,
    required int rating,
  }) async {
    final endpoint = '/api/ratings';
    debugPrint('▶️ postRating 요청 시작 → endpoint=$endpoint, historyId=$historyId, rating=$rating');

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'historyId': historyId,
          'rating': rating,
        },
      );

      debugPrint(
        '✅ postRating 응답 [${response.statusCode}]\n'
        'data=${response.data}',
      );
    } on DioException catch (e, stack) {
      debugPrint('❌ postRating DioError 발생 → type=${e.type}, message=${e.message}');
      if (e.response != null) {
        debugPrint('  Response [${e.response?.statusCode}]: ${e.response?.data}');
      }
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ postRating 알 수 없는 에러 발생 → $e');
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    }
  }

  Future<void> postFoodRating({
    required int historyId,
    required int rating,
  }) async {
    final endpoint = '/api/ratings/foods';
    debugPrint('▶️ postFoodRating 요청 시작 → endpoint=$endpoint, historyId=$historyId, rating=$rating');

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'historyId': historyId,
          'rating': rating,
        },
      );

      debugPrint(
        '✅ postFoodRating 응답 [${response.statusCode}]\n'
        'data=${response.data}',
      );
    } on DioException catch (e, stack) {
      debugPrint('❌ postFoodRating DioError 발생 → type=${e.type}, message=${e.message}');
      if (e.response != null) {
        debugPrint('  Response [${e.response?.statusCode}]: ${e.response?.data}');
      }
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ postFoodRating 알 수 없는 에러 발생 → $e');
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    }
  }

  Future<BeautyHistoryResponse> fetchBeautyHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    // nextPageKey가 있으면 있는 그대로 넣고, 없으면 생략
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (nextPageKey != null)
        'nextPageKey': nextPageKey, // Uri.encodeComponent 제거
    };
    debugPrint("nextPageKey::::::::::::::$nextPageKey");
    debugPrint("queryParams::::$queryParams");

    final response = await _dio.get(
      '/api/recomendation-history/beauty-history',
      queryParameters: queryParams, // Dio가 자동으로 한 번만 인코딩해 줌
    );
    return BeautyHistoryResponse.fromJson(response.data);
  }

  Future<FoodsHistoryResponse> fetchFoodsHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (nextPageKey != null)
        'nextPageKey': nextPageKey,
    };

    debugPrint('▶️ fetchFoodsHistories 요청 시작 → endpoint=/api/recomendation-history/foods-history, params=$queryParams');

    try {
      final response = await _dio.get(
        '/api/recomendation-history/foods-history',
        queryParameters: queryParams,
      );

      debugPrint(
        '✅ fetchFoodsHistories 응답 [${response.statusCode}]\n'
        'data=${response.data}',
      );

      return FoodsHistoryResponse.fromJson(response.data);
    } on DioException catch (e, stack) {
      debugPrint('❌ fetchFoodsHistories DioError 발생 → type=${e.type}, message=${e.message}');
      if (e.response != null) {
        debugPrint('  Response [${e.response?.statusCode}]: ${e.response?.data}');
      }
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ fetchFoodsHistories 알 수 없는 에러 발생 → $e');
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    }
  }

  Future<CareHistoryResponse> fetchCareHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (nextPageKey != null)
        'nextPageKey': nextPageKey,
    };

    debugPrint('▶️ fetchCareHistories 요청 시작 → endpoint=/api/recomendation-history/care-history, params=$queryParams');

    try {
      final response = await _dio.get(
        '/api/recomendation-history/care-history',
        queryParameters: queryParams,
      );

      debugPrint(
        '✅ fetchCareHistories 응답 [${response.statusCode}]\n'
        'data=${response.data}',
      );

      return CareHistoryResponse.fromJson(response.data);
    } on DioException catch (e, stack) {
      debugPrint('❌ fetchCareHistories DioError 발생 → type=${e.type}, message=${e.message}');
      if (e.response != null) {
        debugPrint('  Response [${e.response?.statusCode}]: ${e.response?.data}');
      }
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ fetchCareHistories 알 수 없는 에러 발생 → $e');
      debugPrint('  StackTrace:\n$stack');
      rethrow;
    }
  }
}
