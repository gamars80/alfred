import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../../call/model/product.dart';
import '../model/product.dart';

class ProductPageResult {
  final List<Product> items;
  final String? nextCursor;
  final int totalCount; // ← 추가

  ProductPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,  // ← 생성자에 포함
  });

  factory ProductPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => Product.fromJson(item))
        .toList();
    return ProductPageResult(
      items: items,
      nextCursor: json['nextCursor'],
      totalCount: (json['totalCount'] as num).toInt(),  // ← JSON 의 count 파싱
    );
  }
}

class SearchRepository {
  final Dio _dio = DioClient.dio;
  final int pageSize;

  SearchRepository({this.pageSize = 20});

  Future<ProductPageResult> fetchProductsByCategory({
    required String category,
    String? cursor,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? searchKeyword,
  }) async {
    final uri = '/api/products/search';
    final params = {
      'category': category,
      'sortBy': sortBy,
      'sortDir': sortDir,
      'limit': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      return ProductPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }
}
