import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/paginated_command_authority_history.dart';

class CommandAuthorityService {
  final Dio _dio = DioClient.dio;

  Future<PaginatedCommandAuthorityHistory> getCommandAuthorityHistory({
    int page = 0,
    int size = 20,
  }) async {
    final uri = '/api/self/command-authority/history';
    debugPrint('📡 [GET] $uri');

    try {
      final response = await _dio.get(
        uri,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      debugPrint('✅ [RESPONSE ${response.statusCode}] $uri');
      debugPrint('   응답 데이터: ${response.data}');

      return PaginatedCommandAuthorityHistory.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [DioException] $uri');
      debugPrint('    ▶ message: ${e.message}');
      debugPrint('    ▶ response.statusCode: ${e.response?.statusCode}');
      debugPrint('    ▶ response.data: ${e.response?.data}');
      rethrow;
    } catch (e, st) {
      debugPrint('❌ [Unexpected Error] $uri');
      debugPrint('    ▶ error: $e');
      debugPrint('    ▶ stackTrace: $st');
      rethrow;
    }
  }
} 