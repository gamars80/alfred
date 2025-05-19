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

class CallScreenBody extends StatefulWidget {
  final int createdAt;
  final Map<String, List<Product>> categorizedProducts;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;

  const CallScreenBody({
    super.key,
    required this.createdAt,
    required this.categorizedProducts,
    required this.communityPosts,
    required this.events,
    required this.hospitals,
    required this.youtubeVideos,
  });

  @override
  State<CallScreenBody> createState() => _CallScreenBodyState();
}

class _CallScreenBodyState extends State<CallScreenBody> with TickerProviderStateMixin {
  String selectedSource = '강남언니';
  int selectedProcedureTab = 0;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedProcedureTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];

    if (widget.communityPosts.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 커뮤니티'),
      ));

      items.addAll(widget.communityPosts.map((post) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: CommunityCard(
          post: post,
          source: post.source,
          historyCreatedAt: widget.createdAt,
          initialLiked: post.liked,
        ),
      )));
    }

    if (widget.events.isNotEmpty || widget.hospitals.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 시술'),
      ));

      items.add(TabBar(
        controller: _tabController,
        labelColor: Colors.deepPurple,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.deepPurple,
        tabs: const [
          Tab(text: '이벤트'),
          Tab(text: '병원'),
        ],
      ));

      items.add(const SizedBox(height: 12));

      if (selectedProcedureTab == 0) {
        final filteredEvents = widget.events
            .where((e) => e.source?.trim() == selectedSource.trim())
            .toList();

        items.add(_buildSourceFilter());
        items.add(const SizedBox(height: 8));

        // 기존 Map → List 변환부를 이렇게 바꿔주세요.
        items.addAll(filteredEvents.map((e) => Padding(
          key: ValueKey('event-${e.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: EventCard(event: e, historyCreatedAt: widget.createdAt),
        )));
      } else {
        items.addAll(widget.hospitals.map((h) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: HospitalCard(hospital: h, historyCreatedAt: widget.createdAt),
        )));
      }
    }

    if (widget.youtubeVideos.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: _buildSectionTitle('추천 Youtube 영상'),
      ));
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: YouTubeList(videos: widget.youtubeVideos),
      ));
    }

    if (widget.categorizedProducts.isNotEmpty) {
      final nonEmptyProductEntries = widget.categorizedProducts.entries.where((e) => e.value.isNotEmpty);
      items.addAll(nonEmptyProductEntries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(entry.key),
            const SizedBox(height: 8),
             ...entry.value.map((p) => ProductCard(
               product: p,
               historyCreatedAt: widget.createdAt,   // ← 여기에 넘겨줌
             )).toList(),
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
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }

  Widget _buildSourceFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton('강남언니'),
          const SizedBox(width: 8),
          _buildFilterButton('바비톡'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String source) {
    final isSelected = selectedSource == source;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            selectedSource = source;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          source,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
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
