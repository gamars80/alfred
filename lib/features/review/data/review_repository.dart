import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/review.dart';

class ReviewRepository {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<Review>> fetchReviews(String productId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reviews/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('리뷰 로딩 실패');
    }
  }
}