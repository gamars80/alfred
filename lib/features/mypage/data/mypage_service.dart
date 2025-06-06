import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/common/dio/dio_client.dart';

class MyPageService {
  final Dio _dio = DioClient.dio;

  Future<bool> withdrawUser() async {
    const uri = '/api/user/withdraw';
    debugPrint('📡 [DELETE] $uri');

    try {
      final response = await _dio.delete(uri);

      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      debugPrint('   응답 데이터: ${response.data}');
      
      return true;
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri');
      debugPrint('    ▶ message: ${e.message}');
      debugPrint('    ▶ response.statusCode: ${e.response?.statusCode}');
      debugPrint('    ▶ response.data: ${e.response?.data}');
      return false;
    } catch (e, st) {
      debugPrint('❌ [Unexpected Error] $uri');
      debugPrint('    ▶ error: $e');
      debugPrint('    ▶ stackTrace: $st');
      return false;
    }
  }
} 