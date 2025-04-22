import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../service/token_manager.dart';
import '../model/popular_product.dart';

class PopularRepository {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<PopularProduct>> fetchPopularProducts() async {
    final token = await TokenManager.getToken();
    final uri = Uri.parse('$baseUrl/api/likes/popular');

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => PopularProduct.fromJson(e)).toList();
    } else {
      throw Exception('인기 상품 데이터를 불러오지 못했습니다.');
    }
  }
}