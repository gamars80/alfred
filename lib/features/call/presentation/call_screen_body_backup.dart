import 'dart:io';

import 'package:alfred_clean/features/call/presentation/widget/beauty_command_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/community_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/event_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/hospital_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/youtube_list.dart';
import 'package:alfred_clean/features/call/presentation/widget/product_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/care_product_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/fashion_command_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/foods_command_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/care_command_card.dart';
import 'package:flutter/material.dart';
import '../data/beauty_api.dart';
import '../data/food_api.dart';
import '../data/care_api.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/recent_beauty_command.dart';
import '../model/recent_foods_command.dart';
import '../model/youtube_video.dart';
import '../data/product_api.dart';
import 'widget/food_products_grid.dart';

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
  final String selectedCategory;
  final String? recipeSummary;
  final String? requiredIngredients;
  final String? suggestionReason;
  final String? reason; // 뷰티케어 추천 이유

  const CallScreenBody({
    super.key,
    required this.id,
    required this.createdAt,
    required this.categorizedProducts,
    required this.communityPosts,
    required this.events,
    required this.hospitals,
    required this.youtubeVideos,
    required this.selectedCategory,
    this.recipeSummary,
    this.requiredIngredients,
    this.suggestionReason,
    this.reason,
  });

  @override
  State<CallScreenBody> createState() => _CallScreenBodyState();
}

class _CallScreenBodyState extends State<CallScreenBody> with TickerProviderStateMixin {
  String selectedSource = '강남언니';
  int selectedProcedureTab = 0;
  int selectedFashionTab = 0;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late TabController _fashionTabController;
  bool _isReasonExpanded = false; // 추천이유 섹션 접기/펼치기 상태

  // ===== 뷰티 명령 관련 상태 추가 =====
  List<RecentBeautyCommand> _recentBeautyCommands = [];
  bool _isLoadingBeautyCommands = false;

  List<RecentFashionCommand> _recentCommands = [];
  bool _isLoadingCommands = false;

  // ===== 음식 명령 관련 상태 추가 =====
  List<RecentFoodsCommand> _recentFoodsCommands = [];
  bool _isLoadingFoodsCommands = false;

  // ===== 뷰티케어 명령 관련 상태 추가 =====
  List<RecentCareCommand> _recentCareCommands = [];
  bool _isLoadingCareCommands = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fashionTabController = TabController(length: 4, vsync: this); // 4개 탭으로 변경
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedProcedureTab = _tabController.index;
        });
      }
    });
    _fashionTabController.addListener(() {
      if (!_fashionTabController.indexIsChanging) {
        setState(() {
          selectedFashionTab = _fashionTabController.index;
        });
      }
    });
    _loadRecentCommands();
    _loadRecentBeautyCommands();
    _loadRecentFoodsCommands();
    _loadRecentCareCommands();
  }

  @override
  void didUpdateWidget(CallScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory == '쇼핑' && widget.categorizedProducts.isNotEmpty) {
      final sources = widget.categorizedProducts.keys.toList();
      if (sources.isNotEmpty && !sources.contains(selectedSource)) {
        setState(() {
          selectedSource = sources[0];
        });
      }
    } else if (widget.selectedCategory == '시술/성형') {
      // 현재 selectedSource가 '강남언니' 또는 '바비톡'이 아니면만 초기화
      if (selectedSource != '강남언니' && selectedSource != '바비톡') {
        setState(() {
          selectedSource = '강남언니';
        });
      }
    }
  }

  Future<void> _loadRecentCommands() async {
    if (_isLoadingCommands) return;
    if (!mounted) return;
    setState(() => _isLoadingCommands = true);
    try {
      final commands = await ProductApi().fetchRecentFashionCommands();
      if (mounted) {
        setState(() => _recentCommands = commands);
      }
    } catch (e) {
      debugPrint('❌ Failed to load recent commands: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCommands = false);
      }
    }
  }

  Future<void> _loadRecentBeautyCommands() async {
    if (_isLoadingBeautyCommands) return;
    if (!mounted) return;
    setState(() => _isLoadingBeautyCommands = true);
    try {
      final beautyCommands = await BeautyApi().fetchRecentBeautyCommands(limit: 10);
      if (mounted) {
        setState(() => _recentBeautyCommands = beautyCommands);
      }
    } catch (e) {
      debugPrint('❌ Failed to load recent beauty commands: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBeautyCommands = false);
      }
    }
  }

  Future<void> _loadRecentFoodsCommands() async {
    if (_isLoadingFoodsCommands) return;
    if (!mounted) return;
    setState(() => _isLoadingFoodsCommands = true);
    try {
      final commands = await FoodApi().fetchRecentFoodsCommands();
      if (mounted) {
        setState(() => _recentFoodsCommands = commands);
      }
    } catch (e) {
      debugPrint('❌ Failed to load recent foods commands: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFoodsCommands = false);
      }
    }
  }

  Future<void> _loadRecentCareCommands() async {
    if (_isLoadingCareCommands) return;
    if (!mounted) return;
    setState(() => _isLoadingCareCommands = true);
    try {
      final commands = await CareApi().fetchRecentCareCommands();
      if (mounted) {
        setState(() => _recentCareCommands = commands);
      }
    } catch (e) {
      debugPrint('❌ Failed to load recent care commands: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCareCommands = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _fashionTabController.dispose();
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
        children: _buildSections(context),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    debugPrint('buildSections called, selectedSource: $selectedSource');
    final sections = <Widget>[];

    // Debug prints to check the values
    debugPrint('Community posts: ${widget.communityPosts.length}');
    debugPrint('Events: ${widget.events.length}');
    debugPrint('Hospitals: ${widget.hospitals.length}');
    debugPrint('Recent fashion commands: ${_recentCommands.length}');
    debugPrint('Recent beauty commands: ${_recentBeautyCommands.length}');
    debugPrint('Recent foods commands: ${_recentFoodsCommands.length}');
    debugPrint('Recent care commands: ${_recentCareCommands.length}');
    debugPrint('Selected category: ${widget.selectedCategory}');
    debugPrint('Categorized products: ${widget.categorizedProducts}');
    debugPrint('Selected source: $selectedSource');
    if (widget.selectedCategory == '쇼핑') {
      debugPrint('Available sources: ${widget.categorizedProducts.keys.toList()}');
      debugPrint('Products for selected source: ${widget.categorizedProducts[selectedSource]?.length ?? 0}');
    }

    // 뷰티케어 카테고리이고 추천이유가 있을 때 추천이유 섹션을 맨 위에 추가
    if (widget.selectedCategory == '뷰티케어' && widget.reason != null && widget.reason!.isNotEmpty) {
      sections.add(_buildReasonSection());
    }

    // 다른 추천 컨텐츠가 있을 때는 최신 명령 섹션을 생략
    final bool hasRecommendedContent =
        widget.communityPosts.isNotEmpty ||
            widget.events.isNotEmpty ||
            widget.hospitals.isNotEmpty ||
            widget.youtubeVideos.isNotEmpty ||
            widget.categorizedProducts.isNotEmpty;

    // 다른 추천 컨텐츠가 없을 때만 "최신 패션/뷰티/음식/뷰티케어 명령" 섹션 표시
    if (!hasRecommendedContent && (_recentCommands.isNotEmpty || _recentBeautyCommands.isNotEmpty || _recentFoodsCommands.isNotEmpty || _recentCareCommands.isNotEmpty)) {
      sections.add(
        Column(
          children: [
            // 패션 / 시술성형 / 음식 / 뷰티케어 탭바
            _buildFashionTabBar(),
            const SizedBox(height: kSpacing),

            // ====== 패션 탭 ======
            if (selectedFashionTab == 0 && _recentCommands.isNotEmpty)
              _buildSection(
                title: '최신 인기 패션 명령',
                children: _recentCommands
                    .map((command) => FashionCommandCard(command: command))
                    .toList(),
              ),

            // ====== 시술성형 탭 ======
            if (selectedFashionTab == 1 && _recentBeautyCommands.isNotEmpty)
              _buildSection(
                title: '최신 인기 뷰티 명령',
                children: _recentBeautyCommands
                    .map((command) => BeautyCommandCard(command: command))
                    .toList(),
              ),

            // ====== 음식/식자재 탭 ======
            if (selectedFashionTab == 2 && _recentFoodsCommands.isNotEmpty)
              _buildSection(
                title: '최신 인기 음식 명령',
                children: _recentFoodsCommands
                    .map((command) => FoodsCommandCard(command: command))
                    .toList(),
              ),

            // ====== 뷰티케어 탭 ======
            if (selectedFashionTab == 3 && _recentCareCommands.isNotEmpty)
              _buildSection(
                title: '최신 인기 뷰티케어 명령',
                children: _recentCareCommands
                    .map((command) => CareCommandCard(command: command))
                    .toList(),
              ),
          ],
        ),
      );
    }

    // 커뮤니티 섹션
    if (widget.communityPosts.isNotEmpty) {
      sections.add(
        _buildSection(
          title: '추천 커뮤니티',
          children: widget.communityPosts.map((post) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacing,
                vertical: kSpacing / 4,
              ),
              child: _buildElevatedCard(
                child: CommunityCard(
                  post: post,
                  source: post.source,
                  historyCreatedAt: widget.createdAt,
                  initialLiked: post.liked,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // 시술(이벤트/병원) 섹션
    if (widget.events.isNotEmpty || widget.hospitals.isNotEmpty) {
      sections.add(
        _buildSection(
          title: '추천 시술',
          children: [
            _buildCustomTabBar(),
            const SizedBox(height: kSpacing),
            if (selectedProcedureTab == 0) ...[
              _buildSourceFilter(),
              const SizedBox(height: kSpacing / 2),
              // 필터링 후 남은 이벤트 개수와 각 이벤트 정보 로그
              ...(() {
                final filteredEvents = widget.events
                    .where((e) {
                      final eventMallName = (e.source ?? '').trim();
                      final selected = selectedSource.trim();
                      debugPrint('[이벤트 필터] e.source: "' + eventMallName + '" | selectedSource: "' + selected + '"');
                      return eventMallName == selected;
                    })
                    .toList();
                debugPrint('필터 후 남은 이벤트 개수: \\${filteredEvents.length}');
                for (final e in filteredEvents) {
                  debugPrint('렌더링할 이벤트: id=\\${e.id}, title=\\${e.title}, source=\\${e.source}');
                }
                return filteredEvents.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacing,
                      vertical: kSpacing / 2,
                    ),
                    child: _buildElevatedCard(
                      child: EventCard(
                        key: ValueKey('eventcard-${e.id}-${e.source}'),
                        event: e,
                        historyCreatedAt: widget.createdAt,
                      ),
                    ),
                  );
                }).toList();
              })(),
            ] else ...[
              ...widget.hospitals.map((h) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacing,
                    vertical: kSpacing / 2,
                  ),
                  child: _buildElevatedCard(
                    child: HospitalCard(
                      hospital: h,
                      historyCreatedAt: widget.createdAt,
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      );
    }

    // YouTube 섹션
    if (widget.youtubeVideos.isNotEmpty) {
      sections.add(
        _buildSection(
          title: '추천 YouTube 영상',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: _buildElevatedCard(
                child: YouTubeList(videos: widget.youtubeVideos),
              ),
            ),
          ],
        ),
      );
    }

    // 쇼핑 상품 섹션
    if (widget.categorizedProducts.isNotEmpty) {
      if (widget.selectedCategory == '음식/식자재') {
        sections.add(
          FoodProductsGrid(
            products: widget.categorizedProducts,
            historyId: widget.id,
            recipeSummary: widget.recipeSummary,
            requiredIngredients: widget.requiredIngredients,
            suggestionReason: widget.suggestionReason,
          ),
        );
      } else {
        // 패션 상품 등 다른 카테고리의 상품들
        final nonEmptyProductEntries = widget.categorizedProducts.entries
            .where((e) => e.value.isNotEmpty);

        sections.addAll(
          nonEmptyProductEntries.map((entry) {
            return _buildSection(
              title: entry.key,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        MediaQuery.of(context).size.width <= 320 ? 0.55 : 0.6,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: widget.selectedCategory == '뷰티케어' ?
                        265 : Platform.isIOS ? 320 : 290
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      // 뷰티케어 카테고리일 때는 CareProductCard 사용
                      if (widget.selectedCategory == '뷰티케어') {
                        return CareProductCard(
                          id: widget.id,
                          product: entry.value[index],
                          historyCreatedAt: widget.createdAt,
                        );
                      } else {
                        // 다른 카테고리는 기존 ProductCard 사용
                        return ProductCard(
                          id: widget.id,
                          product: entry.value[index],
                          historyCreatedAt: widget.createdAt,
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        );
      }
    }

    // 아무런 추천 컨텐츠가 없으면 안내 문구 노출
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
        ),
      ];
    }

    return sections;
  }

  Widget _buildReasonSection() {
    return Container(
      margin: const EdgeInsets.all(kSpacing),
      padding: const EdgeInsets.all(kSpacing),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '추천 이유',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isReasonExpanded = !_isReasonExpanded;
                  });
                },
                icon: Icon(
                  _isReasonExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (_isReasonExpanded) ...[
            const SizedBox(height: 12),
            Text(
              widget.reason!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFashionTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _fashionTabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          gradient: const LinearGradient(
            colors: [kPrimaryColor, kSecondaryColor],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: kPrimaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: '패션'),
          Tab(text: '뷰티'),
          Tab(text: '음식'),
          Tab(text: '케어'),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          gradient: const LinearGradient(
            colors: [kPrimaryColor, kSecondaryColor],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: kPrimaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: '이벤트'),
          Tab(text: '병원'),
        ],
      ),
    );
  }

  Widget _buildSourceFilter() {
    if (widget.selectedCategory != '시술/성형') return const SizedBox.shrink();

    final sources = ['강남언니', '바비톡'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: sources.map((source) {
          final isSelected = selectedSource == source;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedSource = source;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  source,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing / 2),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: kSpacing),
      ],
    );
  }

  Widget _buildElevatedCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: child,
      ),
    );
  }
} 