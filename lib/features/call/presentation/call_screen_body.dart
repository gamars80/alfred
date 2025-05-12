// ✅ call_screen_body.dart
import 'package:alfred_clean/features/call/presentation/widget/community_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/event_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/hospital_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/youtube_list.dart';
import 'package:alfred_clean/features/call/presentation/widget/product_card.dart';
import 'package:flutter/material.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/youtube_video.dart';


class CallScreenBody extends StatelessWidget {
  final int createdAt;
  final Map<String, List<Product>> categorizedProducts;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;
  final int selectedProcedureTab;
  final ValueChanged<int> onProcedureTabChanged;

  const CallScreenBody({
    super.key,
    required this.createdAt,
    required this.categorizedProducts,
    required this.communityPosts,
    required this.events,
    required this.hospitals,
    required this.youtubeVideos,
    required this.selectedProcedureTab,
    required this.onProcedureTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];

    if (communityPosts.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 커뮤니티'),
      ));

      items.addAll(communityPosts.map((post) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: CommunityCard(
          post: post,
          source: post.source,
          historyCreatedAt: createdAt,
          initialLiked: post.liked,
        ),
      )));
    }

    if (events.isNotEmpty || hospitals.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 시술'),
      ));
      items.add(_buildEventHospitalTabs());
    }

    if (youtubeVideos.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 Youtube 영상'),
      ));
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: YouTubeList(videos: youtubeVideos),
      ));
    }

    if (categorizedProducts.isNotEmpty) {
      final nonEmptyProductEntries = categorizedProducts.entries.where((e) => e.value.isNotEmpty);
      items.addAll(nonEmptyProductEntries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(entry.key),
            const SizedBox(height: 8),
            ...entry.value.map((p) => ProductCard(product: p)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      )));
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('추천된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }

  Widget _buildEventHospitalTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            onTap: onProcedureTabChanged,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(text: '이벤트'),
              Tab(text: '병원'),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedProcedureTab == 0)
            ...events.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: EventCard(event: e, historyCreatedAt: createdAt,),
            )),
          if (selectedProcedureTab == 1)
            ...hospitals.map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HospitalCard(hospital: h),
            )),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
