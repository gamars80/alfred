import 'package:flutter/material.dart';
import '../../call/data/beauty_api.dart';
import '../../call/data/food_api.dart';
import '../../call/data/care_api.dart';
import '../../call/data/product_api.dart';
import '../model/chat_message.dart';

class OpenAIChatService {
  static Future<ChatMessage> sendMessage(String userMessage) async {
    try {
      // 백엔드 API 호출하여 AI 응답과 추천 데이터를 함께 가져오기
      final metadata = await _analyzeAndFetchRecommendations(userMessage);
      
      return ChatMessage.ai(
        '요청하신 내용을 처리했습니다! 🎉\n\n추천 결과를 확인해보세요.',
        metadata: metadata,
      );
    } catch (e) {
      return ChatMessage.ai(
        '죄송합니다. 응답을 생성하는데 실패했습니다. 다시 시도해주세요.',
        metadata: {'type': 'error'},
      );
    }
  }

  static Future<Map<String, dynamic>?> _analyzeAndFetchRecommendations(
    String userMessage,
  ) async {
    try {
      final foodApi = FoodApi();
      final productApi = ProductApi();
      final careApi = CareApi();
      final beautyApi = BeautyApi();

      // 키워드 기반으로 적절한 API 호출
      final lowerMessage = userMessage.toLowerCase();
      
      if (_containsKeywords(lowerMessage, ['음식', '먹', '레시피', '요리', '식당', '맛집'])) {
        final result = await foodApi.fetchFoodRecommendation(userMessage);
        return {'foodRecommendation': result};
      }
      
      if (_containsKeywords(lowerMessage, ['패션', '쇼핑', '의류', '신발', '가방', '액세서리'])) {
        final result = await productApi.fetchRecommendedProducts(userMessage);
        return {'products': result.items};
      }
      
      if (_containsKeywords(lowerMessage, ['뷰티', '화장품', '스킨케어', '메이크업', '헤어'])) {
        final result = await careApi.fetchRecommendedCareProducts(userMessage);
        return {'careProducts': result.items};
      }
      
      if (_containsKeywords(lowerMessage, ['병원', '의료', '시술', '성형', '피부과', '치과'])) {
        final result = await beautyApi.fetchBeautyData(userMessage);
        return {'beautyData': result};
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 추천 데이터 가져오기 실패: $e');
      return null;
    }
  }

  static bool _containsKeywords(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
} 