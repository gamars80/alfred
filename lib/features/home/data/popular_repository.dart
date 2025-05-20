import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/popular_beauty_hospital.dart';
import '../model/popular_community.dart';
import '../model/popular_event.dart';
import '../model/popular_product.dart';
import '../model/popular_weekly_event.dart';

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



}
