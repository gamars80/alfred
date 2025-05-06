// ✅ recommendation_service.dart

import '../data/beauty_api.dart';
import '../data/product_api.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/youtube_video.dart';

class RecommendationResult {
  final Map<String, List<Product>> products;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;

  RecommendationResult({
    this.products = const {},
    this.communityPosts = const [],
    this.events = const [],
    this.hospitals = const [],
    this.youtubeVideos = const [],
  });
}

class RecommendationService {
  static Future<bool> fetch({
    required String query,
    required String selectedCategory,
    required void Function(RecommendationResult data) onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      if (selectedCategory == '쇼핑') {
        final api = ProductApi();
        final result = await api.fetchRecommendedProducts(query);
        onSuccess(RecommendationResult(products: result));
      } else {
        final api = BeautyApi();
        final result = await api.fetchBeautyData(query);
        onSuccess(RecommendationResult(
          communityPosts: result.communityPosts,
          events: result.events,
          hospitals: result.hospitals,
          youtubeVideos: result.youtubeVideos,
        ));
      }
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Not Gender')) {
        onError('gender');
      } else if (msg.contains('Not Age')) {
        onError('age');
      } else if (msg.contains('More Information')) {
        onError('both');
      } else {
        onError('unknown');
      }
      return false;
    }
  }
}
