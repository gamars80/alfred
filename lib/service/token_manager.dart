import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _accessTokenKey = 'accessToken';

  /// 저장된 JWT 토큰을 가져옵니다.
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('JWT 토큰이 존재하지 않습니다. 로그인이 필요합니다.');
    }
    return token;
  }

// 필요에 따라 토큰 저장, 삭제 메서드도 추가할 수 있습니다.
}