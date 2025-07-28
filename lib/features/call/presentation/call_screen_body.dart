// 🎨 Modern Call Screen Body - Redesigned with enhanced UI/UX
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

// 🎨 Modern Design System
class CallBodyTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color backgroundGradientStart = Color(0xFFf8fafc);
  static const Color backgroundGradientEnd = Color(0xFFe2e8f0);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const double spacing = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

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
  final String? reason;

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
  bool _isReasonExpanded = false;

  List<RecentBeautyCommand> _recentBeautyCommands = [];
  bool _isLoadingBeautyCommands = false;
  List<RecentFashionCommand> _recentCommands = [];
  bool _isLoadingCommands = false;
  List<RecentFoodsCommand> _recentFoodsCommands = [];
  bool _isLoadingFoodsCommands = false;
  List<RecentCareCommand> _recentCareCommands = [];
  bool _isLoadingCareCommands = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fashionTabController = TabController(length: 4, vsync: this);
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CallBodyTheme.backgroundGradientStart,
            CallBodyTheme.backgroundGradientEnd,
          ],
        ),
      ),
      child: Column(
        children: [
          // 헤더 (뒤로가기 버튼 없이)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI 추천 결과',
                    style: TextStyle(
                      color: CallBodyTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.selectedCategory.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.selectedCategory} 카테고리',
                      style: TextStyle(
                        color: CallBodyTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 고정된 탭 영역
          _buildFixedTabArea(),
          // 스크롤 가능한 콘텐츠
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: CallBodyTheme.spacing / 2),
              children: _buildScrollableSections(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedTabArea() {
    // 추천 컨텐츠가 없을 때만 탭 표시
    final bool hasRecommendedContent =
        widget.communityPosts.isNotEmpty ||
            widget.events.isNotEmpty ||
            widget.hospitals.isNotEmpty ||
            widget.youtubeVideos.isNotEmpty ||
            widget.categorizedProducts.isNotEmpty;

    if (!hasRecommendedContent && (_recentCommands.isNotEmpty || _recentBeautyCommands.isNotEmpty || _recentFoodsCommands.isNotEmpty || _recentCareCommands.isNotEmpty)) {
      return Column(
        children: [
          _buildModernFashionTabBar(),
          const SizedBox(height: CallBodyTheme.spacing),
        ],
      );
    }

    // 시술/성형 카테고리일 때 탭 표시
    if (widget.selectedCategory == '시술/성형' && (widget.events.isNotEmpty || widget.hospitals.isNotEmpty)) {
      return Column(
        children: [
          _buildModernCustomTabBar(),
          const SizedBox(height: CallBodyTheme.spacing),
          _buildModernSourceFilter(),
          const SizedBox(height: CallBodyTheme.spacing / 2),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  List<Widget> _buildSections(BuildContext context) {
    final sections = <Widget>[];

    // 뷰티케어 추천 이유 섹션
    if (widget.selectedCategory == '뷰티케어' && widget.reason != null && widget.reason!.isNotEmpty) {
      sections.add(_buildModernReasonSection());
    }

    // 추천 컨텐츠가 없을 때 최신 명령 섹션 표시
    final bool hasRecommendedContent =
        widget.communityPosts.isNotEmpty ||
            widget.events.isNotEmpty ||
            widget.hospitals.isNotEmpty ||
            widget.youtubeVideos.isNotEmpty ||
            widget.categorizedProducts.isNotEmpty;

    if (!hasRecommendedContent && (_recentCommands.isNotEmpty || _recentBeautyCommands.isNotEmpty || _recentFoodsCommands.isNotEmpty || _recentCareCommands.isNotEmpty)) {
      sections.add(
        Column(
          children: [
            if (selectedFashionTab == 0 && _recentCommands.isNotEmpty)
              _buildModernSection(
                title: '최신 인기 패션 명령',
                icon: Icons.style,
                children: _recentCommands
                    .map((command) => FashionCommandCard(command: command))
                    .toList(),
              ),
            if (selectedFashionTab == 1 && _recentBeautyCommands.isNotEmpty)
              _buildModernSection(
                title: '최신 인기 뷰티 명령',
                icon: Icons.face,
                children: _recentBeautyCommands
                    .map((command) => BeautyCommandCard(command: command))
                    .toList(),
              ),
            if (selectedFashionTab == 2 && _recentFoodsCommands.isNotEmpty)
              _buildModernSection(
                title: '최신 인기 음식 명령',
                icon: Icons.restaurant,
                children: _recentFoodsCommands
                    .map((command) => FoodsCommandCard(command: command))
                    .toList(),
              ),
            if (selectedFashionTab == 3 && _recentCareCommands.isNotEmpty)
              _buildModernSection(
                title: '최신 인기 뷰티케어 명령',
                icon: Icons.spa,
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
        _buildModernSection(
          title: '추천 커뮤니티',
          icon: Icons.forum,
          children: widget.communityPosts.map((post) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CallBodyTheme.spacing,
                vertical: CallBodyTheme.spacing / 4,
              ),
              child: _buildModernCard(
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

    // 시술 섹션
    if (widget.events.isNotEmpty || widget.hospitals.isNotEmpty) {
      sections.add(
        _buildModernSection(
          title: '추천 시술',
          icon: Icons.medical_services,
          children: [
            if (selectedProcedureTab == 0) ...[
              ...(() {
                final filteredEvents = widget.events
                    .where((e) {
                      final eventMallName = (e.source ?? '').trim();
                      final selected = selectedSource.trim();
                      return eventMallName == selected;
                    })
                    .toList();
                return filteredEvents.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CallBodyTheme.spacing,
                      vertical: CallBodyTheme.spacing / 2,
                    ),
                    child: _buildModernCard(
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
                    horizontal: CallBodyTheme.spacing,
                    vertical: CallBodyTheme.spacing / 2,
                  ),
                  child: _buildModernCard(
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
        _buildModernSection(
          title: '추천 YouTube 영상',
          icon: Icons.play_circle_filled,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing),
              child: _buildModernCard(
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
        final nonEmptyProductEntries = widget.categorizedProducts.entries
            .where((e) => e.value.isNotEmpty);

        sections.addAll(
          nonEmptyProductEntries.map((entry) {
            return _buildModernSection(
              title: entry.key,
              icon: Icons.shopping_bag,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing),
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
                      if (widget.selectedCategory == '뷰티케어') {
                        return CareProductCard(
                          id: widget.id,
                          product: entry.value[index],
                          historyCreatedAt: widget.createdAt,
                        );
                      } else {
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

    // 빈 상태 처리
    if (sections.isEmpty) {
      return [
        _buildEmptyState(),
      ];
    }

    return sections;
  }

  List<Widget> _buildScrollableSections(BuildContext context) {
    return _buildSections(context);
  }

  Widget _buildModernReasonSection() {
    return Container(
      margin: const EdgeInsets.all(CallBodyTheme.spacing),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CallBodyTheme.primaryGradientStart,
            CallBodyTheme.primaryGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: CallBodyTheme.primaryGradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isReasonExpanded = !_isReasonExpanded;
            });
          },
          borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(CallBodyTheme.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '추천 이유',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isReasonExpanded ? '접기' : '자세히 보기',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isReasonExpanded ? 0.5 : 0.0,
                      duration: CallBodyTheme.animationDuration,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (_isReasonExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.reason!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFashionTabBar() {
    final tabs = [
      {'name': '패션', 'icon': Icons.style, 'color': const Color(0xFF667eea)},
      {'name': '뷰티', 'icon': Icons.face, 'color': const Color(0xFFf093fb)},
      {'name': '음식', 'icon': Icons.restaurant, 'color': const Color(0xFFed8936)},
      {'name': '케어', 'icon': Icons.spa, 'color': const Color(0xFF48bb78)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CallBodyTheme.cardBackground,
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedFashionTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _fashionTabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: CallBodyTheme.animationDuration,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            tab['color'] as Color,
                            (tab['color'] as Color).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius - 4),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (tab['color'] as Color).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: CallBodyTheme.animationDuration,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tab['icon'] as IconData,
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tab['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernCustomTabBar() {
    final tabs = [
      {'name': '이벤트', 'icon': Icons.event, 'color': const Color(0xFF667eea)},
      {'name': '병원', 'icon': Icons.local_hospital, 'color': const Color(0xFFf093fb)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CallBodyTheme.cardBackground,
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedProcedureTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: CallBodyTheme.animationDuration,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            tab['color'] as Color,
                            (tab['color'] as Color).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius - 4),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (tab['color'] as Color).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: CallBodyTheme.animationDuration,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tab['icon'] as IconData,
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tab['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernSourceFilter() {
    if (widget.selectedCategory != '시술/성형') return const SizedBox.shrink();

    final sources = [
      {'name': '강남언니', 'icon': Icons.forum, 'color': const Color(0xFF667eea)},
      {'name': '바비톡', 'icon': Icons.chat_bubble, 'color': const Color(0xFFf093fb)},
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CallBodyTheme.cardBackground,
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: sources.map((source) {
          final isSelected = selectedSource == source['name'] as String;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedSource = source['name'] as String;
                });
              },
              child: AnimatedContainer(
                duration: CallBodyTheme.animationDuration,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            source['color'] as Color,
                            (source['color'] as Color).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius - 4),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (source['color'] as Color).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: CallBodyTheme.animationDuration,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        source['icon'] as IconData,
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      source['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : CallBodyTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernSection({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CallBodyTheme.spacing, vertical: CallBodyTheme.spacing / 2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      CallBodyTheme.primaryGradientStart,
                      CallBodyTheme.primaryGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CallBodyTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: CallBodyTheme.spacing),
      ],
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: CallBodyTheme.cardBackground,
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CallBodyTheme.borderRadius),
        child: child,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(CallBodyTheme.spacing * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CallBodyTheme.primaryGradientStart,
                  CallBodyTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: CallBodyTheme.spacing),
          const Text(
            '추천된 데이터가 없습니다',
            style: TextStyle(
              color: CallBodyTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '음성 명령으로 새로운 추천을 받아보세요',
            style: TextStyle(
              color: CallBodyTheme.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

