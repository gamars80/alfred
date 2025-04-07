import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductApi {
  static final _baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<List<Product>> fetchRecommendedProducts(String query) async {
    if (_baseUrl.isEmpty) {
      throw Exception('BASE_URL이 .env에서 설정되지 않았습니다.');
    }

    final url = Uri.parse('$_baseUrl/api/ai-search');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('상품 추천 API 호출 실패: ${response.body}');
    }
  }
}
