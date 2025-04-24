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

        final isPublic = options.path.contains('/auth/login') || options.path.contains('/auth/signup');
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
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          debugPrint('[Dio] 401 Unauthorized → GoRouter로 이동');
          final context = navigatorKey.currentContext;
          if (context != null) {
            context.go('/login'); // ✅ 핵심 라인
          }
        }
        handler.next(error);
      },
    ),
  );
}
