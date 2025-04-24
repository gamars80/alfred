import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/review.dart';

class ReviewRepository {
  final Dio _dio = DioClient.dio;

  Future<List<Review>> fetchReviews({
    required String productId,
    required String mallName,
    required String productLink,
  }) async {
    final queryParams = {
      'source': mallName,
    };

    if (mallName == 'HOTPING') {
      final encodedLink = Uri.encodeComponent(productLink);
      queryParams['encodedLink'] = encodedLink;
    }

    try {
      final response = await _dio.get(
        '/api/reviews/$productId',
        queryParameters: queryParams,
      );
      return (response.data as List).map((e) => Review.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('[리뷰 에러] ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }

    // return (response.data as List).map((e) => Review.fromJson(e)).toList();
  }
}