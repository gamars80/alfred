import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/login_response.dart';
import '../model/signup_response.dart';
class AuthApi {
  static final _baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<LoginResponse> loginWithKakaoId(String loginId) async {
    if (_baseUrl.isEmpty) {
      throw Exception('BASE_URL이 .env에서 설정되지 않았습니다.');
    }

    final url = Uri.parse('$_baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'loginId': loginId}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LoginResponse.fromJson(json);
    } else {
      throw Exception('백엔드 로그인 실패: ${response.body}');
    }
  }

  static Future<SignupResponse> registerKakaoUser({
    required String loginId,
    required String email,
    required String name,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/signup');

    final body = {
      'loginId': loginId,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'joinType': 'KAKAO',
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return SignupResponse.fromJson(json);
    } else {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }
}
