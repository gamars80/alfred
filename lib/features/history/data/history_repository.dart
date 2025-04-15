import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:alfred_clean/service/token_manager.dart';
import '../model/history_response.dart';

class HistoryRepository {
  final String baseUrl;

  HistoryRepository() : baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<HistoryResponse> fetchHistories({int limit = 10, String? nextPageKey}) async {
    final token = await TokenManager.getToken();
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final uri = Uri.parse(
        '$baseUrl/api/recomendation-history?limit=$limit${nextPageKey != null ? '&nextPageKey=$nextPageKey' : ''}');
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(decoded);
      return HistoryResponse.fromJson(data);
    } else {
      throw Exception('히스토리 데이터를 가져오는데 실패했습니다. (status: ${response.statusCode})');
    }
  }
}
