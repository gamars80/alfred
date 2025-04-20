import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../service/token_manager.dart';
import '../model/liked_product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LikeRepository {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<LikedProduct>> fetchLikedProducts() async {
    final token = await TokenManager.getToken();
    final uri = Uri.parse('$baseUrl/api/likes/me');

    final response = await http.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => LikedProduct.fromJson(e)).toList();
    } else {
      throw Exception('찜 목록 불러오기 실패: ${response.statusCode}');
    }
  }
}
