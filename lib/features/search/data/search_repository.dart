import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../../call/model/product.dart';
import '../model/review.dart';
import '../model/keyword_review.dart';
import '../model/food_review.dart';
import '../../home/model/popular_recipe.dart';

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

class ReviewPageResult {
  final List<Review> items;
  final String? nextCursor;
  final int totalCount;

  ReviewPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  factory ReviewPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => Review.fromJson(item))
        .toList();
    return ReviewPageResult(
      items: items,
      nextCursor: json['nextCursor'],
      totalCount: (json['totalCount'] as num).toInt(),
    );
  }
}

class KeywordReviewPageResult {
  final List<KeywordReview> items;
  final String? nextCursor;
  final int totalCount;

  KeywordReviewPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  factory KeywordReviewPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => KeywordReview.fromJson(item))
        .toList();
    return KeywordReviewPageResult(
      items: items,
      nextCursor: json['nextCursor'],
      totalCount: (json['totalCount'] as num).toInt(),
    );
  }
}

class FoodReviewPageResult {
  final List<FoodReview> items;
  final String? nextCursor;
  final int totalCount;

  FoodReviewPageResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  factory FoodReviewPageResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => FoodReview.fromJson(item))
        .toList();
    return FoodReviewPageResult(
      items: items,
      nextCursor: json['nextCursor'],
      totalCount: (json['totalCount'] as num).toInt(),
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
      
      // 디버깅: API 응답 전체 출력
      debugPrint('API 응답 데이터: ${response.data}');
      if (response.data['items'] != null && response.data['items'].isNotEmpty) {
        debugPrint('첫 번째 상품 JSON: ${response.data['items'][0]}');
      }
      
      return ProductPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  Future<ProductPageResult> fetchProductsBySource({
    required String source,
    String? cursor,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? searchKeyword,
  }) async {
    final uri = '/api/products/search';
    final params = {
      'source': source,
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
      
      // 디버깅: API 응답 전체 출력
      debugPrint('API 응답 데이터: ${response.data}');
      if (response.data['items'] != null && response.data['items'].isNotEmpty) {
        debugPrint('첫 번째 상품 JSON: ${response.data['items'][0]}');
      }
      
      return ProductPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  Future<ProductPageResult> fetchAllProducts({
    String? cursor,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? searchKeyword,
  }) async {
    final uri = '/api/products/search';
    final params = {
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
      
      // 디버깅: API 응답 전체 출력
      debugPrint('API 응답 데이터: ${response.data}');
      if (response.data['items'] != null && response.data['items'].isNotEmpty) {
        debugPrint('첫 번째 상품 JSON: ${response.data['items'][0]}');
      }
      
      return ProductPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  Future<ReviewPageResult> fetchReviews({
    String? category,
    String? source,
    String? cursor,
    String? searchKeyword,
  }) async {
    final uri = '/api/reviews/search';
    final params = {
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      'limit': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      return ReviewPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  Future<KeywordReviewPageResult> fetchKeywordReviews({
    required String keyword,
    String? cursor,
    bool? hasEvent,
    String? searchText,
  }) async {
    final uri = '/api/reviews/beauty/search';
    final params = {
      'keyword': keyword,
      'limit': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (hasEvent != null) 'hasEvent': hasEvent,
      if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final result = KeywordReviewPageResult.fromJson(response.data);
      if (result.items.isEmpty && result.totalCount > 0) {
        throw Exception('Failed to parse review data');
      }

      return result;
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [Error] $uri\n▶ message: $e');
      rethrow;
    }
  }

  // 음식 재료로 상품 검색
  Future<ProductPageResult> fetchProductsByIngredient({
    required String ingredient,
    String? cursor,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? searchKeyword,
    String? source,
  }) async {
    final uri = '/api/products/ai-foods/search';
    final params = {
      'keyword': ingredient,
      'sortBy': sortBy,
      'sortDir': sortDir,
      'limit': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (source != null) 'source': source,
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

  // 음식 재료로 리뷰 검색
  Future<ReviewPageResult> fetchReviewsByIngredient({
    required String ingredient,
    String? cursor,
    String? searchKeyword,
  }) async {
    final uri = '/api/reviews/food/search';
    final params = {
      'ingredient': ingredient,
      'limit': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      return ReviewPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  // 음식 리뷰 검색 (새로운 API)
  Future<FoodReviewPageResult> fetchFoodReviews({
    String? keyword,
    String? source,
    String? cursor,
    String? mallName,
    String? searchKeyword,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final uri = '/api/reviews/foods/search';
    final params = {
      'limit': pageSize,
      'sortBy': sortBy,
      'sortDir': sortDir,
      if (keyword != null) 'keyword': keyword,
      if (source != null) 'source': source,
      if (cursor != null) 'cursor': cursor,
      if (mallName != null) 'mallName': mallName,
      if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      return FoodReviewPageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  // 레시피 검색
  Future<List<PopularRecipe>> fetchRecipes({
    required String keyword,
    int limit = 10,
  }) async {
    final uri = '/api/products/ai-recipes/search';
    final params = {
      'keyword': keyword,
      'limit': limit,
    };

    debugPrint('📡 [GET] $uri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(uri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      return (response.data['items'] as List)
          .map((item) => PopularRecipe.fromJson(item))
          .toList();
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri\n▶ message: ${e.message}');
      rethrow;
    }
  }

  // AI 레시피 검색 (페이지네이션 지원)
  Future<RecipePageResult> fetchAiRecipes({
    required String keyword,
    String? cursor,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    int limit = 20,
    String? source,
    String? searchKeyword,
  }) async {
    final aiRecipesUri = '/api/products/ai-recipes/search';
    final params = {
      'keyword': keyword,
      'sortBy': sortBy,
      'sortDir': sortDir,
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (source != null) 'source': source,
      if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
    };

    debugPrint('📡 [GET] $aiRecipesUri');
    debugPrint('    ▶ queryParameters: $params');

    try {
      final response = await _dio.get(aiRecipesUri, queryParameters: params);
      debugPrint('✅ [RESPONSE ${response.statusCode}] $aiRecipesUri');
      return RecipePageResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $aiRecipesUri\n▶ message: ${e.message}');
      rethrow;
    }
  }
}

