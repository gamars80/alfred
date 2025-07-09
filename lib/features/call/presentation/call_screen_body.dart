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
      // 쇼핑 카테고리이고 상품이 있을 때, 첫 번째 available source를 selectedSource로 설정
      final sources = widget.categorizedProducts.keys.toList();
      if (sources.isNotEmpty && selectedSource != sources[0]) {
        setState(() {
          selectedSource = sources[0];
        });
      }
    } else if (widget.selectedCategory == '시술/성형' && selectedSource != '강남언니') {
      // 시술/성형 카테고리일 때는 '강남언니'로 초기화
      setState(() {
        selectedSource = '강남언니';
      });
    }
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

  Future<void> _loadRecentBeautyCommands() async {
    if (_isLoadingBeautyCommands) return;
    setState(() => _isLoadingBeautyCommands = true);
    try {
      final beautyCommands = await BeautyApi().fetchRecentBeautyCommands(limit: 10);
      setState(() => _recentBeautyCommands = beautyCommands);
    } catch (e) {
      debugPrint('❌ Failed to load recent beauty commands: $e');
    } finally {
      setState(() => _isLoadingBeautyCommands = false);
    }
  }

  Future<void> _loadRecentFoodsCommands() async {
    if (_isLoadingFoodsCommands) return;
    setState(() => _isLoadingFoodsCommands = true);
    try {
      final commands = await FoodApi().fetchRecentFoodsCommands();
      setState(() => _recentFoodsCommands = commands);
    } catch (e) {
      debugPrint('❌ Failed to load recent foods commands: $e');
    } finally {
      setState(() => _isLoadingFoodsCommands = false);
    }
  }

  Future<void> _loadRecentCareCommands() async {
    if (_isLoadingCareCommands) return;
    setState(() => _isLoadingCareCommands = true);
    try {
      final commands = await CareApi().fetchRecentCareCommands();
      setState(() => _recentCareCommands = commands);
    } catch (e) {
      debugPrint('❌ Failed to load recent care commands: $e');
    } finally {
      setState(() => _isLoadingCareCommands = false);
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
                title: '최신 패션 명령',
                children: _recentCommands
                    .map((command) => FashionCommandCard(command: command))
                    .toList(),
              ),

            // ====== 시술성형 탭 ======
            if (selectedFashionTab == 1 && _recentBeautyCommands.isNotEmpty)
              _buildSection(
                title: '최신 뷰티 명령',
                children: _recentBeautyCommands
                    .map((command) => BeautyCommandCard(command: command))
                    .toList(),
              ),

            // ====== 음식/식자재 탭 ======
            if (selectedFashionTab == 2 && _recentFoodsCommands.isNotEmpty)
              _buildSection(
                title: '최신 음식 명령',
                children: _recentFoodsCommands
                    .map((command) => FoodsCommandCard(command: command))
                    .toList(),
              ),

            // ====== 뷰티케어 탭 ======
            if (selectedFashionTab == 3 && _recentCareCommands.isNotEmpty)
              _buildSection(
                title: '최신 뷰티케어 명령',
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
              ...widget.events
                  .where((e) => e.source?.trim() == selectedSource.trim())
                  .map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacing,
                    vertical: kSpacing / 2,
                  ),
                  child: _buildElevatedCard(
                    child: EventCard(
                      event: e,
                      historyCreatedAt: widget.createdAt,
                    ),
                  ),
                );
              })
                  .toList(),
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
                        mainAxisExtent: widget.selectedCategory == '뷰티케어' ? 240 : 285
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    // "최신 패션 명령" 또는 "최신 뷰티 명령"인 경우 단순 텍스트로 표시
    final bool isSimpleCommand =
        title == '최신 패션 명령' || title == '최신 뷰티 명령';

    return Padding(
      padding: const EdgeInsets.only(top: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSimpleCommand)
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
    // 쇼핑 카테고리일 때는 쇼핑몰 소스만 표시
    if (widget.selectedCategory == '쇼핑') {
      final sources = widget.categorizedProducts.keys.toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacing),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sources.map((source) {
              return Padding(
                padding: const EdgeInsets.only(right: kSpacing / 4),
                child: _buildFilterButton(source),
              );
            }).toList(),
          ),
        ),
      );
    }

    // 시술/성형 카테고리일 때는 강남언니, 바비톡만 표시
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

  Widget _buildFashionTabBar() {
    return Container(
      margin: const EdgeInsets.only(left: kSpacing, right: 8),
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
        controller: _fashionTabController,
        labelColor: kPrimaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: kPrimaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        isScrollable: true,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(
            child: Text(
              '패션',
              textAlign: TextAlign.left,
            ),
          ),
          Tab(
            child: Text(
              '시술성형',
              textAlign: TextAlign.left,
            ),
          ),
          Tab(
            child: Text(
              '음식/식자재',
              textAlign: TextAlign.left,
            ),
          ),
          Tab(
            child: Text(
              '뷰티케어',
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF7B1FA2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '알프레드의 추천이유',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            initiallyExpanded: _isReasonExpanded,
            onExpansionChanged: (value) {
              setState(() {
                _isReasonExpanded = value;
              });
            },
            tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE1BEE7),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.reason!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

