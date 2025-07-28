// 🎨 Modern History Screen - Redesigned with enhanced UI/UX
import 'package:flutter/material.dart';
import 'package:alfred_clean/features/history/data/history_repository.dart';
import 'package:alfred_clean/features/history/model/recommendation_history.dart';
import 'package:alfred_clean/features/history/model/beauty_history.dart';
import 'package:alfred_clean/features/history/model/foods_history.dart';
import 'package:alfred_clean/features/history/model/care_history.dart';
import 'package:alfred_clean/features/history/presentation/widget/history_card.dart';
import 'package:alfred_clean/features/history/presentation/widget/beauty_history_card.dart';
import 'package:alfred_clean/features/history/presentation/widget/foods_history_card.dart';
import 'package:alfred_clean/features/history/presentation/widget/care_history_card.dart';
import 'package:alfred_clean/features/history/presentation/history_detail_screen.dart';
import 'beauty_history_detail_screen.dart';
import 'foods_history_detail_screen.dart';
import 'care_history_detail_screen.dart';

// 🎨 Modern Design System
class HistoryScreenTheme {
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

class HistoryScreen extends StatefulWidget {
  final int? selectedBeautyTab;
  final int? selectedFoodTab;
  final int? selectedBeautyCareTab;
  const HistoryScreen({Key? key, this.selectedBeautyTab, this.selectedFoodTab, this.selectedBeautyCareTab}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final HistoryRepository repository = HistoryRepository();
  final ScrollController _shoppingController = ScrollController();
  final ScrollController _communityController = ScrollController();
  final ScrollController _foodController = ScrollController();
  final ScrollController _careController = ScrollController();

  // 쇼핑 탭 상태
  List<RecommendationHistory> _histories = [];
  String? _nextPageKey;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;

  // 시술커뮤니티 탭 상태
  List<BeautyHistory> _beautyHistories = [];
  String? _beautyNextPageKey;
  bool _isBeautyLoadingMore = false;
  bool _hasMoreBeauty = true;
  bool _isBeautyInitialLoading = true;

  // 음식/식자재 탭 상태
  List<FoodsHistory> _foodsHistories = [];
  String? _foodsNextPageKey;
  bool _isFoodsLoadingMore = false;
  bool _hasMoreFoods = true;
  bool _isFoodsInitialLoading = true;

  // 뷰티 탭 상태
  List<CareHistory> _careHistories = [];
  String? _careNextPageKey;
  bool _isCareLoadingMore = false;
  bool _hasMoreCare = true;
  bool _isCareInitialLoading = true;

  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    
    // selectedBeautyTab, selectedFoodTab, selectedBeautyCareTab이 설정되어 있으면 해당 탭을 초기 인덱스로 설정
    final initialIndex = widget.selectedBeautyCareTab ?? widget.selectedFoodTab ?? widget.selectedBeautyTab ?? 0;
    _tabController = TabController(
      length: 4, 
      vsync: this,
      initialIndex: initialIndex,
    )..addListener(_handleTabSelection);

    // selectedBeautyTab, selectedFoodTab, selectedBeautyCareTab이 설정되어 있으면 해당 탭의 데이터도 로드
    if (widget.selectedBeautyTab != null || widget.selectedFoodTab != null || widget.selectedBeautyCareTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTabSelection();
      });
    }

    // 쇼핑 탭 스크롤 리스너
    _shoppingController.addListener(() {
      // 초기 로딩 중 혹은 페이징 로딩 중일 땐 절대 _loadMore 호출 금지
      if (_isInitialLoading || _isLoadingMore) return;
      if (_shoppingController.position.pixels >=
          _shoppingController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });

    // 시술커뮤니티 탭 스크롤 리스너
    _communityController.addListener(() {
      if (_isBeautyInitialLoading || _isBeautyLoadingMore) return;
      if (_communityController.position.pixels >=
          _communityController.position.maxScrollExtent - 200) {
        _loadMoreBeauty();
      }
    });

    // 음식/식자재 탭 스크롤 리스너
    _foodController.addListener(() {
      if (_isFoodsInitialLoading || _isFoodsLoadingMore) return;
      if (_foodController.position.pixels >=
          _foodController.position.maxScrollExtent - 200) {
        _loadMoreFoods();
      }
    });

    // 뷰티 탭 스크롤 리스너
    _careController.addListener(() {
      if (_isCareInitialLoading || _isCareLoadingMore) return;
      if (_careController.position.pixels >=
          _careController.position.maxScrollExtent - 200) {
        _loadMoreCare();
      }
    });

    // selectedBeautyTab이 설정되지 않은 경우에만 첫 번째 탭 초기 로딩
    if (widget.selectedBeautyTab == null) {
      _loadInitialHistories();
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    
    debugPrint('🔄 탭 변경: ${_tabController.index}');
    
    if (_tabController.index == 0) {
      setState(() => _isInitialLoading = true);
      _loadInitialHistories();
    } else if (_tabController.index == 1) {
      setState(() => _isBeautyInitialLoading = true);
      _loadInitialBeautyHistories();
    } else if (_tabController.index == 2) {
      setState(() => _isFoodsInitialLoading = true);
      _loadInitialFoodsHistories();
    } else if (_tabController.index == 3) {
      setState(() => _isCareInitialLoading = true);
      _loadInitialCareHistories();
    }
  }

  Future<void> _loadInitialHistories() async {
    setState(() => _isInitialLoading = true);
    try {
      final response = await repository.fetchHistories(limit: _limit);
      setState(() {
        _histories    = response.histories;
        _nextPageKey  = response.nextPageKey;
        _hasMore      = (_nextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading histories: $e');
    } finally {
      setState(() => _isInitialLoading = false);
      // 로딩 끝나면 스크롤을 맨 위로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_shoppingController.hasClients) {
          _shoppingController.jumpTo(0);
        }
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final response = await repository.fetchHistories(
        limit: _limit,
        nextPageKey: _nextPageKey,
      );
      setState(() {
        _histories.addAll(response.histories);
        _nextPageKey = response.nextPageKey;
        _hasMore = (_nextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading more histories: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadInitialBeautyHistories() async {
    setState(() => _isBeautyInitialLoading = true);
    try {
      final response = await repository.fetchBeautyHistories(limit: _limit);
      setState(() {
        _beautyHistories  = response.histories;
        _beautyNextPageKey= response.nextPageKey;
        _hasMoreBeauty    = (_beautyNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading beauty histories: $e');
    } finally {
      setState(() => _isBeautyInitialLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_communityController.hasClients) {
          _communityController.jumpTo(0);
        }
      });
    }
  }

  Future<void> _loadMoreBeauty() async {
    if (_isBeautyLoadingMore || !_hasMoreBeauty) return;
    setState(() => _isBeautyLoadingMore = true);
    try {
      final response = await repository.fetchBeautyHistories(
        limit: _limit,
        nextPageKey: _beautyNextPageKey,
      );
      setState(() {
        _beautyHistories.addAll(response.histories);
        _beautyNextPageKey = response.nextPageKey;
        _hasMoreBeauty = (_beautyNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading more beauty histories: $e');
    } finally {
      setState(() => _isBeautyLoadingMore = false);
    }
  }

  Future<void> _loadInitialFoodsHistories() async {
    setState(() => _isFoodsInitialLoading = true);
    try {
      final response = await repository.fetchFoodsHistories(limit: _limit);
      setState(() {
        _foodsHistories  = response.histories;
        _foodsNextPageKey= response.nextPageKey;
        _hasMoreFoods    = (_foodsNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading foods histories: $e');
    } finally {
      setState(() => _isFoodsInitialLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_foodController.hasClients) {
          _foodController.jumpTo(0);
        }
      });
    }
  }

  Future<void> _loadMoreFoods() async {
    if (_isFoodsLoadingMore || !_hasMoreFoods) return;
    setState(() => _isFoodsLoadingMore = true);
    try {
      final response = await repository.fetchFoodsHistories(
        limit: _limit,
        nextPageKey: _foodsNextPageKey,
      );
      setState(() {
        _foodsHistories.addAll(response.histories);
        _foodsNextPageKey = response.nextPageKey;
        _hasMoreFoods = (_foodsNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading more foods histories: $e');
    } finally {
      setState(() => _isFoodsLoadingMore = false);
    }
  }

  Future<void> _loadInitialCareHistories() async {
    setState(() => _isCareInitialLoading = true);
    try {
      final response = await repository.fetchCareHistories(limit: _limit);
      setState(() {
        _careHistories  = response.histories;
        _careNextPageKey= response.nextPageKey;
        _hasMoreCare    = (_careNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading care histories: $e');
    } finally {
      setState(() => _isCareInitialLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_careController.hasClients) {
          _careController.jumpTo(0);
        }
      });
    }
  }

  Future<void> _loadMoreCare() async {
    if (_isCareLoadingMore || !_hasMoreCare) return;
    setState(() => _isCareLoadingMore = true);
    try {
      final response = await repository.fetchCareHistories(
        limit: _limit,
        nextPageKey: _careNextPageKey,
      );
      setState(() {
        _careHistories.addAll(response.histories);
        _careNextPageKey = response.nextPageKey;
        _hasMoreCare = (_careNextPageKey?.isNotEmpty ?? false);
      });
    } catch (e) {
      debugPrint('Error loading more care histories: $e');
    } finally {
      setState(() => _isCareLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shoppingController.dispose();
    _communityController.dispose();
    _foodController.dispose();
    _careController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HistoryScreenTheme.backgroundGradientStart,
              HistoryScreenTheme.backgroundGradientEnd,
            ],
          ),
        ),
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(),
            // Modern Tab Bar
            _buildModernTabBar(),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShoppingTab(),
                  _buildCommunityTab(),
                  _buildFoodsTab(),
                  _buildCareTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: HistoryScreenTheme.spacing, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    HistoryScreenTheme.primaryGradientStart,
                    HistoryScreenTheme.primaryGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: HistoryScreenTheme.primaryGradientStart.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.history,
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
                    '히스토리',
                    style: TextStyle(
                      color: HistoryScreenTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '나의 추천 기록을 확인해보세요',
                    style: TextStyle(
                      color: HistoryScreenTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    final tabs = [
      {'name': '쇼핑', 'icon': Icons.shopping_bag, 'color': const Color(0xFF667eea)},
      {'name': '시술커뮤니티', 'icon': Icons.face, 'color': const Color(0xFFf093fb)},
      {'name': '음식/식자재', 'icon': Icons.restaurant, 'color': const Color(0xFFed8936)},
      {'name': '뷰티', 'icon': Icons.spa, 'color': const Color(0xFF48bb78)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: HistoryScreenTheme.spacing),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HistoryScreenTheme.cardBackground,
        borderRadius: BorderRadius.circular(HistoryScreenTheme.borderRadius),
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
          final isSelected = _tabController.index == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: HistoryScreenTheme.animationDuration,
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
                  borderRadius: BorderRadius.circular(HistoryScreenTheme.borderRadius - 4),
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
                      duration: HistoryScreenTheme.animationDuration,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tab['icon'] as IconData,
                        color: isSelected ? Colors.white : HistoryScreenTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tab['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : HistoryScreenTheme.textSecondary,
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

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: HistoryScreenTheme.spacing, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HistoryScreenTheme.cardBackground,
            borderRadius: BorderRadius.circular(HistoryScreenTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 16,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 16,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShoppingTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialHistories,
      child: _isInitialLoading
          ? _buildSkeleton()
          : _histories.isEmpty
          ? _buildEmptyState('쇼핑 히스토리가 없습니다.', Icons.shopping_bag)
          : ListView.builder(
        controller: _shoppingController,
        itemCount: _histories.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _histories.length) {
            return _buildLoadingIndicator();
          }
          return AnimatedContainer(
            duration: HistoryScreenTheme.animationDuration,
            child: HistoryCard(
              history: _histories[idx],
              extractTags: _extractTags,
              onTap: () async {
                final updated = await Navigator.push<RecommendationHistory>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetailScreen(history: _histories[idx]),
                  ),
                );
                if (updated != null) {
                  setState(() => _histories[idx] = updated);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialBeautyHistories,
      child: _isBeautyInitialLoading
          ? _buildSkeleton()
          : _beautyHistories.isEmpty
          ? _buildEmptyState('시술커뮤니티 히스토리가 없습니다.', Icons.face)
          : ListView.builder(
        controller: _communityController,
        itemCount:
        _beautyHistories.length + (_isBeautyLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _beautyHistories.length) {
            return _buildLoadingIndicator();
          }

          final history = _beautyHistories[idx];
          return AnimatedContainer(
            duration: HistoryScreenTheme.animationDuration,
            child: BeautyHistoryCard(
              history: history,
              onTap: () async {
                final updated = await Navigator.push<BeautyHistory>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BeautyHistoryDetailScreen(history: history),
                  ),
                );
                if (updated != null) {
                  setState(() {
                    final idx = _beautyHistories.indexWhere((h) => h.createdAt == updated.createdAt);
                    if (idx != -1) _beautyHistories[idx] = updated;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodsTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialFoodsHistories,
      child: _isFoodsInitialLoading
          ? _buildSkeleton()
          : _foodsHistories.isEmpty
          ? _buildEmptyState('음식/식자재 히스토리가 없습니다.', Icons.restaurant)
          : ListView.builder(
        controller: _foodController,
        itemCount: _foodsHistories.length + (_isFoodsLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _foodsHistories.length) {
            return _buildLoadingIndicator();
          }

          final history = _foodsHistories[idx];
          return AnimatedContainer(
            duration: HistoryScreenTheme.animationDuration,
            child: FoodsHistoryCard(
              history: history,
              onTap: () async {
                final updated = await Navigator.push<FoodsHistory>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodsHistoryDetailScreen(history: history),
                  ),
                );
                if (updated != null) {
                  setState(() {
                    final idx = _foodsHistories.indexWhere((h) => h.id == updated.id);
                    if (idx != -1) _foodsHistories[idx] = updated;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialCareHistories,
      child: _isCareInitialLoading
          ? _buildSkeleton()
          : _careHistories.isEmpty
          ? _buildEmptyState('뷰티 히스토리가 없습니다.', Icons.spa)
          : ListView.builder(
        controller: _careController,
        itemCount: _careHistories.length + (_isCareLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _careHistories.length) {
            return _buildLoadingIndicator();
          }

          final history = _careHistories[idx];
          return AnimatedContainer(
            duration: HistoryScreenTheme.animationDuration,
            child: CareHistoryCard(
              history: history,
              onTap: () async {
                final updated = await Navigator.push<CareHistory>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CareHistoryDetailScreen(history: history),
                  ),
                );
                if (updated != null) {
                  setState(() {
                    final idx = _careHistories.indexWhere((h) => h.id == updated.id);
                    if (idx != -1) _careHistories[idx] = updated;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  HistoryScreenTheme.primaryGradientStart,
                  HistoryScreenTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HistoryScreenTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 추천을 받아보세요!',
            style: TextStyle(
              fontSize: 14,
              color: HistoryScreenTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(HistoryScreenTheme.primaryGradientStart),
        ),
      ),
    );
  }

  List<String> _extractTags(String gptCondition) {
    final tags = <String>[];
    final pattern = RegExp(r'(\w+)=((\[[^\]]*\])|[^,)]*)');
    for (final m in pattern.allMatches(gptCondition)) {
      final raw = m.group(2)?.trim();
      if (raw == null || raw == 'null' || raw.isEmpty) continue;
      if (raw.startsWith('[') && raw.endsWith(']')) {
        for (var item in raw.substring(1, raw.length - 1).split(',')) {
          if (item.trim().isNotEmpty) tags.add('#${item.trim()}');
        }
      } else {
        tags.add('#$raw');
      }
    }
    return tags;
  }
}
