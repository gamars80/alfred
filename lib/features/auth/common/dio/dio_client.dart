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
          // 🚨 여기에 로그 추가!
          debugPrint('[Dio] 요청 URL: ${options.uri}');
          debugPrint('[Dio] Authorization 헤더: Bearer $token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint('[Dio] 토큰 없음 → Authorization 생략됨');
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        debugPrint('[Dio] 에러 발생: ${error.response?.statusCode} - ${error.message}');
        debugPrint('[Dio] 요청 URL: ${error.requestOptions.uri}');
        
        // 401 에러 처리 일시적으로 비활성화 (디버깅용)
        if (error.response?.statusCode == 401) {
          debugPrint('[Dio] 401 Unauthorized 감지됨 (자동 로그아웃 비활성화)');
          debugPrint('[Dio] 에러 응답: ${error.response?.data}');
          
          // 자동 로그아웃 비활성화
          // await TokenManager.clearToken();
          // final context = navigatorKey.currentContext;
          // if (context != null) {
          //   debugPrint('[Dio] 로그인 화면으로 리다이렉트');
          //   context.go('/login');
          // }
          // return;
        }

        handler.next(error);
      },
    ),
  );
}
