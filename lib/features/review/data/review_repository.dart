import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/review.dart';

class ReviewRepository {
  final Dio _dio = DioClient.dio;

  Future<List<Review>> fetchReviews({
    required String productId,
    required String? source,
    required String productLink,
  }) async {
    print('[리뷰 요청 시작] productId: $productId, source $source');

    final queryParams = {
      'source': source,
    };

    if (source == 'HOTPING') {
      final encodedLink = Uri.encodeComponent(productLink);
      queryParams['encodedLink'] = encodedLink;
    }

    try {
      final response = await _dio.get(
        '/api/reviews/$productId',
        queryParameters: queryParams,
      );
      print('[리뷰 응답 수신] ${response.data}');
      return (response.data as List).map((e) => Review.fromJson(e)).toList();
    } on DioException catch (e) {
      print('[리뷰 에러] ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Review>> fetchFoodReviews({
    required String productId,
    required String source,
  }) async {
    print('[음식 리뷰 요청 시작] productId: $productId, source: $source');

    try {
      final response = await _dio.get(
        '/api/reviews/foods/$productId',
        queryParameters: {'source': source},
      );
      print('[음식 리뷰 응답 수신] ${response.data}');
      return (response.data as List).map((e) => Review.fromJson(e)).toList();
    } on DioException catch (e) {
      print('[음식 리뷰 에러] ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Review>> fetchCareReviews({
    required String productId,
    required String source,
  }) async {
    print('[뷰티케어 리뷰 요청 시작] productId: $productId, source: $source');

    try {
      final response = await _dio.get(
        '/api/reviews/care/$productId',
        queryParameters: {'source': source},
      );
      print('[뷰티케어 리뷰 응답 수신] ${response.data}');
      return (response.data as List).map((e) => Review.fromJson(e)).toList();
    } on DioException catch (e) {
      print('[뷰티케어 리뷰 에러] ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}