import 'package:alfred_clean/features/like/domain/models/food_like_model.dart';
import 'package:dio/dio.dart';

class FoodLikeService {
  final Dio _dio;

  FoodLikeService(this._dio);

  Future<Map<String, dynamic>> getLikedFoods({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/api/likes/foods/me',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final List<FoodLikeModel> foods = (response.data['content'] as List)
          .map((item) => FoodLikeModel.fromJson(item))
          .toList();

      return {
        'content': foods,
        'page': response.data['page'],
        'size': response.data['size'],
        'totalPages': response.data['totalPages'],
        'totalElements': response.data['totalElements'],
      };
    } catch (e) {
      throw Exception('Failed to fetch liked foods: $e');
    }
  }
} 