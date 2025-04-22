import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../service/token_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/paginated_liked_products.dart';

class LikeRepository {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final int pageSize;

  LikeRepository({this.pageSize = 20});

  Future<PaginatedLikedProducts> fetchLikedProducts({int page = 0}) async {
    final token = await TokenManager.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/likes/me?page=$page&size=$pageSize',
    );
    final response = await http.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
      json.decode(utf8.decode(response.bodyBytes));
      return PaginatedLikedProducts.fromJson(decoded);
    } else {
      throw Exception('찜 목록 불러오기 실패: ${response.statusCode}');
    }
  }
}