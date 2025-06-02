import 'package:alfred_clean/features/call/presentation/widget/community_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/event_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/hospital_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/youtube_list.dart';
import 'package:alfred_clean/features/call/presentation/widget/product_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/fashion_command_card.dart';
import 'package:flutter/material.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/youtube_video.dart';
import '../data/product_api.dart';

// 디자인 시스템 상수
const kPrimaryColor = Color(0xFF6200EE);
const kSecondaryColor = Color(0xFF03DAC6);
const kBackgroundColor = Color(0xFFF5F5F5);
const kCardBorderRadius = 12.0;
const kSpacing = 16.0;

class CallScreenBody extends StatefulWidget {
  final int id;
  final int createdAt;
  final Map<String, List<Product>> categorizedProducts;
  final List<CommunityPost> communityPosts;
  final List<Event> events;
  final List<Hospital> hospitals;
  final List<YouTubeVideo> youtubeVideos;

  const CallScreenBody({
    super.key,
    required this.id,
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
  List<RecentFashionCommand> _recentCommands = [];
  bool _isLoadingCommands = false;

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
    _loadRecentCommands();
  }

  Future<void> _loadRecentCommands() async {
    if (_isLoadingCommands) return;
    setState(() => _isLoadingCommands = true);
    try {
      final commands = await ProductApi().fetchRecentFashionCommands();
      setState(() => _recentCommands = commands);
    } catch (e) {
      debugPrint('❌ Failed to load recent commands: $e');
    } finally {
      setState(() => _isLoadingCommands = false);
    }
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

    // 배경색 적용을 위해 Container로 감싸기
    return Container(
      color: kBackgroundColor,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: kSpacing / 2),
        children: _buildSections(),
      ),
    );
  }

  List<Widget> _buildSections() {
    final List<Widget> sections = [];

    // 최신 패션 명령 섹션
    if (_recentCommands.isNotEmpty) {
      sections.add(_buildSection(
        title: '최신 패션 명령',
        children: _recentCommands.map((command) => FashionCommandCard(
          command: command,
        )).toList(),
      ));
    }

    // 커뮤니티 섹션
    if (widget.communityPosts.isNotEmpty) {
      sections.add(_buildSection(
        title: '추천 커뮤니티',
        children: widget.communityPosts.map((post) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing / 4),
          child: _buildElevatedCard(
            child: CommunityCard(
              post: post,
              source: post.source,
              historyCreatedAt: widget.createdAt,
              initialLiked: post.liked,
            ),
          ),
        )).toList(),
      ));
    }

    // 시술 섹션
    if (widget.events.isNotEmpty || widget.hospitals.isNotEmpty) {
      sections.add(_buildSection(
        title: '추천 시술',
        children: [
          _buildCustomTabBar(),
          const SizedBox(height: kSpacing),
          if (selectedProcedureTab == 0) ...[
            _buildSourceFilter(),
            const SizedBox(height: kSpacing / 2),
            ...widget.events
                .where((e) => e.source?.trim() == selectedSource.trim())
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kSpacing, vertical: kSpacing / 2),
                      child: _buildElevatedCard(
                        child: EventCard(
                          event: e,
                          historyCreatedAt: widget.createdAt,
                        ),
                      ),
                    ))
                .toList(),
          ] else ...[
            ...widget.hospitals.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kSpacing, vertical: kSpacing / 2),
                  child: _buildElevatedCard(
                    child: HospitalCard(
                      hospital: h,
                      historyCreatedAt: widget.createdAt,
                    ),
                  ),
                ))
          ],
        ],
      ));
    }

    // YouTube 섹션
    if (widget.youtubeVideos.isNotEmpty) {
      sections.add(_buildSection(
        title: '추천 YouTube 영상',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacing),
            child: _buildElevatedCard(
              child: YouTubeList(videos: widget.youtubeVideos),
            ),
          ),
        ],
      ));
    }

    // 제품 섹션
    if (widget.categorizedProducts.isNotEmpty) {
      final nonEmptyProductEntries =
          widget.categorizedProducts.entries.where((e) => e.value.isNotEmpty);
      sections.addAll(nonEmptyProductEntries.map((entry) => _buildSection(
            title: entry.key,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).size.width <= 320 ? 0.55 : 0.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) => ProductCard(
                    id: widget.id,
                    product: entry.value[index],
                    historyCreatedAt: widget.createdAt,
                  ),
                ),
              ),
            ],
          )));
    }

    if (sections.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(kSpacing * 2),
            child: Text(
              '추천된 데이터가 없습니다.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      ];
    }

    return sections;
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    final bool isFashionCommand = title == '최신 패션 명령';
    
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFashionCommand)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E2DE2).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          const SizedBox(height: kSpacing / 2),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: kPrimaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: kPrimaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(
            child: Text(
              '이벤트',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Tab(
            child: Text(
              '병원',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: [
          _buildFilterButton('강남언니'),
          const SizedBox(width: kSpacing / 4),
          _buildFilterButton('바비톡'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String source) {
    final isSelected = selectedSource == source;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            setState(() {
              selectedSource = source;
            });
          }
        },
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            source,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
