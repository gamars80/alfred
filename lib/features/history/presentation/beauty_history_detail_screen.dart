import 'package:flutter/material.dart';

import '../../call/presentation/widget/community_card.dart';
import '../../call/presentation/widget/event_card.dart';
import '../../call/presentation/widget/youtube_list.dart';
import '../model/beauty_history.dart';

class BeautyHistoryDetailScreen  extends StatelessWidget {
  final BeautyHistory history;

  const BeautyHistoryDetailScreen({Key? key, required this.history}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final posts = history.recommendedPostsByGangnam ?? [];
    final events = history.recommendedEventByGangNam ?? [];
    final videos = history.recommendedVideos ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(history.keyword ?? '시술 히스토리 상세')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (posts.isNotEmpty) ...[
            const Text(
              '📌 관련 커뮤니티 게시글',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ 밝은 색으로 설정
              ),
            ),
            const SizedBox(height: 8),
            ...posts.map((post) => CommunityCard(post: post)),
            const SizedBox(height: 20),
          ],
          if (events.isNotEmpty) ...[
            const Text(
              '🎉 이벤트',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ 밝은 색으로 설정
              ),
            ),
            const SizedBox(height: 8),
            ...events.map((event) => EventCard(event: event)),
            const SizedBox(height: 20),
          ],
          if (videos.isNotEmpty) ...[
            const Text(
              '📺 유튜브 영상',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ 밝은 색으로 설정
              ),
            ),
            const SizedBox(height: 8),
            YouTubeList(videos: videos),
          ],
        ],
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
