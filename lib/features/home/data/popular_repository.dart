import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/popular_beauty_hospital.dart';
import '../model/popular_community.dart';
import '../model/popular_event.dart';
import '../model/popular_product.dart';
import '../model/popular_weekly_event.dart';
import '../model/popular_beauty_keyword.dart';
import '../model/popular_food_ingredient.dart';
import '../model/popular_food_product.dart';
import '../model/popular_recipe.dart';
import '../model/popular_care_keyword.dart';
import '../model/popular_care_product.dart';
import '../model/popular_care_like.dart';

class PopularRepository {
  final Dio _dio = DioClient.dio;

  Future<List<PopularProduct>> fetchPopularProducts() async {
    final response = await _dio.get('/api/popular/product');
    return (response.data as List).map((e) => PopularProduct.fromJson(e)).toList();
  }

  Future<List<PopularCommunity>> fetchPopularCommunities() async {
    final response = await _dio.get('/api/popular/community');
    return (response.data as List)
        .map((e) => PopularCommunity.fromJson(e))
        .toList();
  }

  Future<List<PopularEvent>> fetchPopularEvents() async {
    final response = await _dio.get('/api/popular/event');
    return (response.data as List)
        .map((e) => PopularEvent.fromJson(e))
        .toList();
  }

  Future<List<PopularBeautyHospital>> fetchPopularBeautyHospitals() async {
    final response = await _dio.get('/api/popular/hospital');
    return (response.data as List)
        .map((e) => PopularBeautyHospital.fromJson(e))
        .toList();
  }

  Future<List<PopularWeeklyEvent>> fetchPopularWeeklyEvents() async {
    final response = await _dio.get('/api/events/weekly/top');
    return (response.data as List)
        .map((e) => PopularWeeklyEvent.fromJson(e))
        .toList();
  }

  Future<List<PopularProduct>> fetchWeeklyTopProducts() async {
    final response = await _dio.get('/api/products/weekly/top');
    return (response.data as List).map((e) => PopularProduct.fromJson(e)).toList();
  }

  Future<List<String>> fetchWeeklyTopCategories() async {
    final response = await _dio.get('/api/products/weekly/top/category');
    return (response.data as List)
        .map((e) => e['category'] as String)
        .toList();
  }

  Future<List<String>> fetchWeeklyTopSources() async {
    final response = await _dio.get('/api/products/weekly/top/source');
    return (response.data as List)
        .map((e) => e['source'] as String)
        .toList();
  }

  Future<List<PopularBeautyKeyword>> fetchWeeklyTopBeautyKeywords() async {
    final response = await _dio.get('/api/beauty/weekly/top/keyword');
    return (response.data as List)
        .map((e) => PopularBeautyKeyword.fromJson(e))
        .toList();
  }

  Future<List<PopularFoodIngredient>> fetchWeeklyTopFoodIngredients() async {
    final response = await _dio.get('/api/products/weekly/top/food/ingredient');
    return (response.data as List)
        .map((e) => PopularFoodIngredient.fromJson(e))
        .toList();
  }

  Future<List<PopularFoodProduct>> fetchWeeklyTopFoodProducts() async {
    final response = await _dio.get('/api/products/weekly/top/food/products');
    return (response.data as List)
        .map((e) => PopularFoodProduct.fromJson(e))
        .toList();
  }

  Future<List<PopularFoodIngredient>> fetchWeeklyTopFoodRecipeIngredients() async {
    final response = await _dio.get('/api/products/weekly/top/food/recipe/ingredient');
    return (response.data as List)
        .map((e) => PopularFoodIngredient.fromJson(e))
        .toList();
  }

  Future<List<PopularRecipe>> fetchWeeklyTopRecipes() async {
    final response = await _dio.get('/api/products/weekly/top/food/recipes');
    return (response.data as List)
        .map((e) => PopularRecipe.fromJson(e))
        .toList();
  }

  Future<List<PopularCareKeyword>> fetchWeeklyTopCareKeywords() async {
    final response = await _dio.get('/api/products/weekly/top/care/keyword');
    return (response.data as List)
        .map((e) => PopularCareKeyword.fromJson(e))
        .toList();
  }

  Future<List<PopularCareProduct>> fetchWeeklyTopCareProducts() async {
    try {
      print('🔍 Fetching weekly top care products...');
      final response = await _dio.get('/api/products/weekly/top/care/products');
      print('📡 API Response status: ${response.statusCode}');
      print('📡 API Response data: ${response.data}');
      
      if (response.data == null) {
        print('❌ Response data is null');
        return [];
      }
      
      if (response.data is! List) {
        print('❌ Response data is not a List: ${response.data.runtimeType}');
        return [];
      }
      
      final products = (response.data as List).map((e) => PopularCareProduct.fromJson(e)).toList();
      print('✅ Parsed ${products.length} care products');
      return products;
    } catch (e) {
      print('❌ Error fetching weekly top care products: $e');
      rethrow;
    }
  }

  Future<List<PopularCareLike>> fetchPopularCareLikes() async {
    try {
      print('🔍 Fetching popular care likes...');
      final response = await _dio.get('/api/popular/care');
      print('📡 API Response status: ${response.statusCode}');
      print('📡 API Response data: ${response.data}');
      
      if (response.data == null) {
        print('❌ Response data is null');
        return [];
      }
      
      if (response.data is! List) {
        print('❌ Response data is not a List: ${response.data.runtimeType}');
        return [];
      }
      
      final likes = (response.data as List).map((e) => PopularCareLike.fromJson(e)).toList();
      print('✅ Parsed ${likes.length} care likes');
      return likes;
    } catch (e) {
      print('❌ Error fetching popular care likes: $e');
      rethrow;
    }
  }
}
