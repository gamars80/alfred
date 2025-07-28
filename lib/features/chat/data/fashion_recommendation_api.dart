import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../auth/common/dio/dio_client.dart';
import '../model/fashion_recommendation.dart';

/// 패션 추천 API 클래스
/// 
/// 채팅 모드에서 패션 추천을 처리하는 API입니다.
/// 실무 수준의 에러 처리와 로깅을 포함합니다.
class FashionRecommendationApi {
  final Dio _dio = DioClient.dio;

  /// 패션 추천 API 호출
  /// 
  /// [query] 사용자 입력 쿼리 (연령대 정보 포함 가능)
  /// [ageGroup] 선택된 연령대 (TWENTY, THIRTY, FORTY)
  /// 
  /// Returns: [FashionRecommendationResult] 추천 결과
  Future<FashionRecommendationResult> fetchFashionRecommendation(
    String query, {
    String? ageGroup,
  }) async {
    debugPrint('🛍️ [FashionRecommendationApi] query: $query, ageGroup: $ageGroup');
    
    try {
      // 연령대 정보를 쿼리에 포함
      String finalQuery = query;
      if (ageGroup != null) {
        // 연령대 텍스트값으로 변환
        String ageText = '';
        switch (ageGroup) {
          case 'TWENTY':
            ageText = '20대';
            break;
          case 'THIRTY':
            ageText = '30대';
            break;
          case 'FORTY':
            ageText = '40대';
            break;
          default:
            ageText = ageGroup;
        }
        finalQuery = '$query $ageText 여성';
      }

      debugPrint('🛍️ [FashionRecommendationApi] 최종 쿼리: "$finalQuery"');
      debugPrint('🛍️ [FashionRecommendationApi] 전송 데이터: {"query": "$finalQuery"}');

      // 쿼리 검증
      if (finalQuery.trim().length < 3) {
        throw Exception('쿼리가 너무 짧습니다. 더 구체적으로 말씀해주세요.');
      }

      final response = await _dio.post(
        '/api/ai-search',
        data: {'query': finalQuery},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('✅ [FashionRecommendationApi] API 응답 성공: ${data.keys}');

      // 응답 파싱
      final id = data['id'] as int;
      final createdAt = data['createdAt'] as int?;
      if (createdAt == null) {
        throw Exception('API 응답에 "createdAt" 필드가 없습니다');
      }

      // 상품 목록 파싱
      final rawItems = data['items'];
      if (rawItems == null) {
        throw Exception('API 응답에 "items" 필드가 없습니다');
      }

      final itemsMap = (rawItems as Map<String, dynamic>).map((
        category,
        itemsJson,
      ) {
        debugPrint('📂 category="$category", count=${(itemsJson as List).length}');
        
        final products = (itemsJson as List).map((e) {
          try {
            return FashionProduct.fromJson(e as Map<String, dynamic>);
          } catch (err, stack) {
            debugPrint('⚠️ FashionProduct.fromJson 실패: $err\n데이터: $e\n$stack');
            rethrow;
          }
        }).toList();
        
        return MapEntry(category, products);
      });

      // 총 검색 건수 계산
      int totalCount = 0;
      for (final products in itemsMap.values) {
        totalCount += products.length;
      }

      return FashionRecommendationResult(
        id: id,
        createdAt: createdAt,
        items: itemsMap,
        totalCount: totalCount,
        status: 'processing', // 초기 상태는 처리중
      );

    } on DioException catch (e) {
      debugPrint('❌ [FashionRecommendationApi] DioException: type=${e.type}, message=${e.message}');
      debugPrint('❌ [FashionRecommendationApi] Status Code: ${e.response?.statusCode}');
      debugPrint('❌ [FashionRecommendationApi] Response Data: ${e.response?.data}');
      
      final data = e.response?.data;
      
      // 커스텀 에러 메시지 처리 (기존 call 폴더와 동일한 방식)
      if (data is Map<String, dynamic> && data['message'] != null) {
        final message = data['message'] as String;
        debugPrint('🔍 [FashionRecommendationApi] 에러 메시지: "$message"');
        
        if (message.contains('Already Recommend')) {
          debugPrint('✅ [FashionRecommendationApi] Already Recommend 에러 감지');
          throw Exception('alreadyRecommend');
        } else if (message.contains('Not enough Command')) {
          debugPrint('✅ [FashionRecommendationApi] Not enough Command 에러 감지');
          throw Exception('not_enough_command');
        } else if (message.contains('Not ItemType')) {
          debugPrint('✅ [FashionRecommendationApi] Not ItemType 에러 감지');
          throw Exception('itemType');
        } else {
          debugPrint('⚠️ [FashionRecommendationApi] 알 수 없는 에러 메시지: "$message"');
          throw Exception(message);
        }
      }
      
      // Choice Type 예외 처리 (itemTypes가 null이어도 처리)
      if (data is Map<String, dynamic> &&
          data['error'] == 'Choice Type') {
        final itemTypes = data['itemTypes'] as List<dynamic>?;
        if (itemTypes != null) {
          throw FashionChoiceTypeException(List<String>.from(itemTypes));
        }
      }
      
      // 네트워크 에러
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('요청 시간이 초과되었습니다. 다시 시도해주세요.');
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('네트워크 연결을 확인해주세요.');
      }
      
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [FashionRecommendationApi] UnknownError: $e\n$stack');
      rethrow;
    }
  }

  /// 추천 상태 확인 API
  /// 
  /// [recommendationId] 추천 ID
  /// Returns: [FashionRecommendationStatus] 현재 상태
  Future<FashionRecommendationStatus> checkRecommendationStatus(int recommendationId) async {
    debugPrint('🔄 [FashionRecommendationApi] 상태 확인: $recommendationId');
    
    try {
      final response = await _dio.get(
        '/api/ai-search/status/$recommendationId',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'unknown';
      final progress = data['progress'] as int? ?? 0;
      final total = data['total'] as int? ?? 0;

      return FashionRecommendationStatus(
        status: status,
        progress: progress,
        total: total,
      );

    } on DioException catch (e) {
      debugPrint('❌ [FashionRecommendationApi] 상태 확인 실패: ${e.message}');
      return const FashionRecommendationStatus(
        status: 'error',
        progress: 0,
        total: 0,
      );
    }
  }

  /// 최근 패션 추천 히스토리 조회
  Future<List<FashionRecommendationHistory>> fetchRecentHistory() async {
    debugPrint('📚 [FashionRecommendationApi] 최근 히스토리 조회');
    
    try {
      final response = await _dio.get(
        '/api/recomendation-history/recently-recommend-history',
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => FashionRecommendationHistory.fromJson(item)).toList();
      
    } catch (e) {
      debugPrint('❌ [FashionRecommendationApi] 히스토리 조회 실패: $e');
      rethrow;
    }
  }
}

 