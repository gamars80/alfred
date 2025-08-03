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
      onResponse: (response, handler) async {
        // 모든 성공 응답을 중앙에서 핸들링
        debugPrint('[Dio] 응답 성공: ${response.statusCode} - ${response.requestOptions.uri}');
        debugPrint('[Dio] 응답 데이터: ${response.data}');
        
        // 공통 응답 형식 처리 (예: success 필드 체크)
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // 백엔드에서 success: false인 경우 처리
          if (data.containsKey('success') && data['success'] == false) {
            final errorMessage = data['message'] ?? '요청에 실패했습니다';
            debugPrint('[Dio] 백엔드 에러 감지: $errorMessage');
            
            // 에러로 변환하여 onError로 전달
            final error = DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: errorMessage,
            );
            handler.reject(error);
            return;
          }
        }
        
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[Dio] 에러 발생: ${error.response?.statusCode} - ${error.message}');
        debugPrint('[Dio] 요청 URL: ${error.requestOptions.uri}');
        
        // 401 에러 처리 - 안전한 자동 로그아웃 및 로그인 화면 이동
        if (error.response?.statusCode == 401) {
          debugPrint('[Dio] 401 Unauthorized 감지됨 - 자동 로그아웃 실행');
          debugPrint('[Dio] 에러 응답: ${error.response?.data}');
          
          // 로그인 관련 API는 제외 (무한 리다이렉트 방지)
          final isAuthEndpoint = error.requestOptions.path.contains('/auth/login') ||
              error.requestOptions.path.contains('/auth/signup');
          
          if (!isAuthEndpoint) {
            // 토큰 삭제
            await TokenManager.clearToken();
            
            // 안전한 context 접근 및 리다이렉트
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final context = navigatorKey.currentContext;
              if (context != null && context.mounted) {
                debugPrint('[Dio] 로그인 화면으로 리다이렉트');
                context.go('/login');
              } else {
                debugPrint('[Dio] Context가 null이거나 mounted가 아님 - 리다이렉트 실패');
              }
            });
            return;
          } else {
            debugPrint('[Dio] 인증 관련 API에서 401 발생 - 리다이렉트 건너뜀');
          }
        }

        handler.next(error);
      },
    ),
  );
}
