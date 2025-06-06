// ✅ recommendation_service.dart

import 'package:flutter/cupertino.dart';

import '../data/beauty_api.dart';
import '../data/product_api.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/youtube_video.dart';

class RecommendationResult {
  final int id;
  final int createdAt;  // 생성 시점 타임스탬프
  final Map<String, List<Product>> products;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;

  RecommendationResult({
    this.id = 0,
    this.createdAt = 0,
    this.products = const {},
    this.communityPosts = const [],
    this.events = const [],
    this.hospitals = const [],
    this.youtubeVideos = const [],
  });
}

class RecommendedProductsResult {
  final int id;
  final int createdAt;
  final Map<String, List<Product>> items;

  RecommendedProductsResult({
    required this.id,
    required this.createdAt,
    required this.items,
  });
}

class RecommendationService {
  static Future<bool> fetch({
    required String query,
    required String selectedCategory,
    required void Function(RecommendationResult data) onSuccess,
    required void Function(String error) onError,
    required void Function(List<String> itemTypes) onChoiceType,  // Choice Type callback
  }) async {
    try {
      if (selectedCategory == '쇼핑') {
        final api = ProductApi();
        final result = await api.fetchRecommendedProducts(query); // RecommendedProductsResult
        debugPrint("result id::::::::::::::::::::::::${result.id}");
        debugPrint("result id::::::::::::::::::::::::${result.id}");
        debugPrint("result id::::::::::::::::::::::::${result.id}");
        onSuccess(RecommendationResult(
          id: result.id,
          createdAt: result.createdAt,
          products: result.items,
        ));
      } else {
        final api = BeautyApi();
        final result = await api.fetchBeautyData(query);
        onSuccess(RecommendationResult(
          id: 0,
          createdAt: result.createdAt,
          communityPosts: result.communityPosts,
          events: result.events,
          hospitals: result.hospitals,
          youtubeVideos: result.youtubeVideos,
        ));
      }
      return true;
    } on ChoiceTypeException catch (e) {
      // Choice Type 에러 처리: 아이템 리스트만 전달
      onChoiceType(e.itemTypes);
      return false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Not Gender')) {
        onError('gender');
      } else if (msg.contains('Not Age')) {
        onError('age');
      } else if (msg.contains('More Information')) {
        onError('both');
      } else if (msg.contains('Not ItemType')) {
        onError('itemType');
      } else if (msg.contains('Already Recommend')) {
        onError('alreadyRecommend');
      } else if (msg.contains('Not enough Command')) {
        onError('not_enough_command');
      } else {
        onError('unknown');
      }
      return false;
    }
  }
}

