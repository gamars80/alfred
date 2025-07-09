import 'package:flutter/material.dart';

import '../../call/presentation/widget/community_card.dart';
import '../../call/presentation/widget/event_card.dart';
import '../../call/presentation/widget/hospital_card.dart';
import '../../call/presentation/widget/youtube_list.dart';
import '../model/beauty_history.dart';

class BeautyHistoryDetailScreen extends StatefulWidget {
  final BeautyHistory history;

  const BeautyHistoryDetailScreen({Key? key, required this.history})
    : super(key: key);

  @override
  State<BeautyHistoryDetailScreen> createState() =>
      _BeautyHistoryDetailScreenState();
}

class _BeautyHistoryDetailScreenState extends State<BeautyHistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? selectedSource; // null = 전체 필터
  late final List<String> sources;

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 생성
    _tabController = TabController(length: 2, vsync: this)..addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // 탭 변경 시 rebuild
          selectedSource = null; // 탭 변경할 때 필터 초기화 원한다면
        });
      }
    });

    // 이벤트의 unique source 목록
    sources =
        widget.history.recommendedEvents.map((e) => e.source).toSet().toList()
          ..sort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.history.recommendedPostsByGangnam;
    final events = widget.history.recommendedEvents;
    final hospitals = widget.history.recommendedHospitals;
    final videos = widget.history.recommendedVideos;

    // 필터링된 이벤트
    final filteredEvents =
        selectedSource == null
            ? events
            : events.where((e) => e.source == selectedSource).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(widget.history.keyword),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, widget.history),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              // 좋아요 기능 구현
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.black54,
          tabs: const [Tab(text: '이벤트'), Tab(text: '병원')],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 📌 커뮤니티 게시글
          if (posts.isNotEmpty) ...[
            const Text('📌 관련 커뮤니티 게시글', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            ...posts.map(
              (post) => CommunityCard(
                post: post,
                source: post.source,
                historyCreatedAt: widget.history.createdAt,
                initialLiked: post.liked,
                onLikedChanged: (updated) {
                  // 상태 변경 로직
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 탭 컨텐츠
          if (_tabController.index == 0) ...[
            // 이벤트 탭: 필터 칩
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('전체'),
                    selected: selectedSource == null,
                    onSelected: (_) => setState(() => selectedSource = null),
                  ),
                  const SizedBox(width: 8),
                  ...sources.map(
                    (src) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(src),
                        selected: selectedSource == src,
                        onSelected:
                            (_) => setState(() {
                              selectedSource =
                                  (selectedSource == src) ? null : src;
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 이벤트 리스트
            if (filteredEvents.isEmpty)
              const Center(child: Text('조건에 맞는 이벤트가 없습니다.')),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              itemBuilder: (ctx, i) {
                final e = filteredEvents[i];
                return Padding(
                  key: ValueKey('event-${e.id}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    key: ValueKey('eventcard-${e.id}'),
                    event: e,
                    historyCreatedAt: widget.history.createdAt,
                    onLikedChanged: (updated) {
                      // 상태 변경 로직
                    },
                  ),
                );
              },
            ),
          ] else ...[
            // 병원 탭
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hospitals.length,
              itemBuilder: (ctx, i) {
                final h = hospitals[i];
                return Padding(
                  key: ValueKey('hospital-${h.id}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HospitalCard(
                    key: ValueKey('hospitalcard-${h.id}'),
                    hospital: h,
                    historyCreatedAt: widget.history.createdAt,
                    onLikedChanged: (updated) {
                      // 상태 변경 로직
                    },
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 24),

          // 📺 유튜브 영상
          if (videos.isNotEmpty) ...[
            const Text('📺 유튜브 영상', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            YouTubeList(videos: videos),
          ],
        ],
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
