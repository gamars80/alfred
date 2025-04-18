import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alfred_clean/service/token_manager.dart';

class ProductApi {
  final String baseUrl;
  final http.Client client;

  ProductApi({http.Client? client})
      : baseUrl = dotenv.env['BASE_URL'] ?? '',
        client = client ?? http.Client();

  Future<Map<String, List<Product>>> fetchRecommendedProducts(String query) async {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL이 .env에서 설정되지 않았습니다.');
    }

    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl/api/ai-search');

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = jsonDecode(decoded)['items'];

      return jsonMap.map((category, items) {
        final productList = (items as List).map((e) => Product.fromJson(e)).toList();
        return MapEntry(category, productList);
      });
    } else {
      throw Exception('상품 추천 API 호출 실패: ${response.statusCode} ${response.body}');
    }
  }

}
