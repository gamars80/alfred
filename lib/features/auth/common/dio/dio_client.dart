import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alfred_clean/service/token_manager.dart';
import 'package:go_router/go_router.dart';
import '/main.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isPublic = options.path.contains('/auth/login') ||
            options.path.contains('/auth/signup');
        if (!isPublic) {
          final token = await TokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint('[Dio] 토큰 없음 → Authorization 생략됨');
          }
        }
        handler.next(options);
      },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('[Dio] 401 Unauthorized → 자동 로그아웃 처리');

            await TokenManager.clearToken();

            final context = navigatorKey.currentContext;
            if (context != null) {
              context.go('/login'); // ✅ 무조건 로그인 화면으로 이동
            }

            return; // handler.next(error) 호출하지 않음
          }

          handler.next(error);
        }
    ),
  );
}
