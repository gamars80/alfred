import 'package:flutter/foundation.dart';
import '../../call/data/beauty_api.dart';
import '../../call/data/food_api.dart';
import '../../call/data/care_api.dart';
import '../../call/data/product_api.dart';
import '../data/fashion_recommendation_api.dart';
import '../data/beauty_recommendation_api.dart';
import '../data/food_recommendation_api.dart';
import '../data/beauty_care_recommendation_api.dart';

class GuidedChatService {
  static final FoodRecommendationApi _foodApi = FoodRecommendationApi();
  static final BeautyCareRecommendationApi _beautyCareApi = BeautyCareRecommendationApi();
  
  static Future<Map<String, dynamic>> fetchRecommendations(
    String mainCategory,
    String subCategory,
  ) async {
    try {
      // 메인 카테고리가 '추천'인 경우에만 백엔드 API 호출
      if (mainCategory == '추천') {
        final foodApi = FoodApi();
        final productApi = ProductApi();
        final careApi = CareApi();
        final beautyApi = BeautyApi();
        
        switch (subCategory) {
          case '패션쇼핑':
            final fashionApi = FashionRecommendationApi();
            final result = await fashionApi.fetchFashionRecommendation('패션쇼핑 추천');
            return {
              'products': result.items,
              'createdAt': result.createdAt,
              'totalCount': result.totalCount,
              'status': result.status,
            };
          case '성형/시술':
            final beautyRecommendationApi = BeautyRecommendationApi();
            final result = await beautyRecommendationApi.fetchBeautyRecommendation('성형/시술 추천');
            return {
              'beautyRecommendation': result,
            };
          case '뷰티':
            final result = await _beautyCareApi.fetchBeautyCareRecommendation('뷰티 추천');
            return {
              'beautyCareRecommendation': result,
            };
          case '음식/과일/식자재':
            final result = await _foodApi.fetchFoodRecommendation('음식/과일/식자재 추천');
            return {
              'foodRecommendation': result,
            };
          default:
            return {'error': '지원하지 않는 카테고리입니다.'};
        }
      } else if (mainCategory == '보고서') {
        // 보고서는 백엔드에서 처리
        return {
          'type': 'report',
          'category': subCategory,
          'message': '보고서를 생성하고 있습니다...',
        };
      }
      
      return {'error': '지원하지 않는 메인 카테고리입니다.'};
    } catch (e) {
      debugPrint('❌ [GuidedChatService] fetchRecommendations 에러 발생: $e');
      // 에러를 다시 던져서 UI에서 처리할 수 있도록 함
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> generateResponse(
    String userMessage,
    String? mainCategory,
    String? subCategory,
    String? ageGroup,  // 연령대 추가
  ) async {
    try {
      // 백엔드 API 호출하여 AI 응답과 추천 데이터를 함께 가져오기
      if (mainCategory == '추천' && subCategory != null) {
        final foodApi = FoodApi();
        final productApi = ProductApi();
        final careApi = CareApi();
        final beautyApi = BeautyApi();
        
        switch (subCategory) {
          case '패션쇼핑':
            // 새로운 패션 추천 API 사용
            final fashionApi = FashionRecommendationApi();
            final result = await fashionApi.fetchFashionRecommendation(
              userMessage,
              ageGroup: ageGroup,
            );
            return {
              'message': result.generateChatResponse(),
              'fashionRecommendation': result,
            };
          case '성형/시술':
            final beautyRecommendationApi = BeautyRecommendationApi();
            final result = await beautyRecommendationApi.fetchBeautyRecommendation(userMessage);
            return {
              'message': result.generateChatResponse(),
              'beautyRecommendation': result,
            };
          case '뷰티':
            final result = await _beautyCareApi.fetchBeautyCareRecommendation(userMessage);
            return {
              'message': result.generateChatResponse(),
              'beautyCareRecommendation': result,
            };
          case '음식/과일/식자재':
            final result = await _foodApi.fetchFoodRecommendation(userMessage);
            return {
              'message': result.generateChatResponse(),
              'foodRecommendation': result,
            };
          default:
            return {
              'message': '죄송합니다. 해당 카테고리의 추천을 찾을 수 없습니다.',
            };
        }
      } else if (mainCategory == '보고서') {
        // 보고서는 백엔드에서 AI로 생성
        return {
          'message': '보고서를 생성하고 있습니다... 📊\n\n잠시만 기다려주세요.',
        };
      }
      
      return {
        'message': '죄송합니다. 요청을 처리할 수 없습니다.',
      };
    } catch (e) {
      debugPrint('❌ [GuidedChatService] 에러 발생: $e');
      // 에러를 다시 던져서 UI에서 처리할 수 있도록 함
      rethrow;
    }
  }

  static Map<String, List<String>> getMainCategoryKeywords() {
    return {
      '추천': ['추천', '추천해', '추천해줘', '추천해주세요', '추천해주세요', '추천해주세요'],
      '보고서': ['보고서', '리포트', '분석', '통계', '데이터', '트렌드'],
    };
  }

  static Map<String, List<String>> getSubCategoryKeywords() {
    return {
      '패션쇼핑': ['패션', '쇼핑', '의류', '신발', '가방', '액세서리', '스타일'],
      '성형/시술': ['성형', '시술', '병원', '의료', '외과', '피부과', '치과'],
      '뷰티': ['뷰티', '화장품', '스킨케어', '메이크업', '헤어', '네일'],
      '음식/과일/식자재': ['음식', '과일', '식자재', '요리', '레시피', '재료'],
      '트렌드 분석': ['트렌드', '분석', '동향', '시장', '흐름'],
      '소비 패턴': ['소비', '패턴', '구매', '행동', '습관'],
      '시장 동향': ['시장', '동향', '경제', '산업', '업계'],
      '예측 리포트': ['예측', '리포트', '전망', '미래', '전망'],
    };
  }
} 