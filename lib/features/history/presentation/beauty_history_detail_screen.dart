import 'package:flutter/material.dart';
import '../../call/model/event.dart';
import '../../call/model/hostpital.dart';
import '../../call/presentation/widget/community_card.dart';
import '../../call/presentation/widget/event_card.dart';
import '../../call/presentation/widget/hospital_card.dart';
import '../../call/presentation/widget/youtube_list.dart';
import '../model/beauty_history.dart';

class BeautyHistoryDetailScreen extends StatefulWidget {
  final BeautyHistory history;
  const BeautyHistoryDetailScreen({Key? key, required this.history}) : super(key: key);

  @override
  State<BeautyHistoryDetailScreen> createState() => _BeautyHistoryDetailScreenState();
}

class _BeautyHistoryDetailScreenState extends State<BeautyHistoryDetailScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final posts = widget.history.recommendedPostsByGangnam;
    final events = widget.history.recommendedEvents;
    final hospitals = widget.history.recommendedHospitals;
    final videos = widget.history.recommendedVideos;

    // 👇 여기에서 로그 찍기
    print('✅ BeautyHistoryDetailScreen 데이터 체크');
    print('Posts: ${posts.length}');
    print('Events: ${events.length}');
    print('Hospitals: ${hospitals.length}');
    print('Videos: ${videos.length}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(widget.history.keyword),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, widget.history), // 여기서 반환!
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (posts.isNotEmpty) ...[
            const Text('📌 관련 커뮤니티 게시글', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            ...posts.map((post) => CommunityCard(
              post: post,
              source: post.source,
              historyCreatedAt: widget.history.createdAt,
              initialLiked: post.liked,
              onLikedChanged: (updatedPost) {
                final index = widget.history.recommendedPostsByGangnam.indexWhere((p) => p.id == updatedPost.id);
                if (index != -1) {
                  setState(() {
                    widget.history.recommendedPostsByGangnam[index] = updatedPost;
                  });
                }
              },
            )),
            const SizedBox(height: 24),
          ],
          if (events.isNotEmpty || hospitals.isNotEmpty) ...[
            const Text('🏥 추천 시술', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _buildProcedureTabs(events, hospitals),
            const SizedBox(height: 24),
          ],
          if (videos.isNotEmpty) ...[
            const Text('📺 유튜브 영상', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            YouTubeList(videos: videos),
          ]
        ],
      ),
    );
  }

  Widget _buildProcedureTabs(List<Event> events, List<Hospital> hospitals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTabButton('이벤트', 0),
            const SizedBox(width: 8),
            _buildTabButton('병원', 1),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedTab == 0)
          ...events.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EventCard(event: e),
          )),
        if (selectedTab == 1)
          ...hospitals.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HospitalCard(hospital: h),
          )),
      ],
    );
  }

  Widget _buildTabButton(String label, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
