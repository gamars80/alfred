// lib/features/history/presentation/history_screen.dart
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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

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
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(_handleTabSelection);

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

    // 첫 번째 탭 초기 로딩
    _loadInitialHistories();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
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
        _foodsHistories = response.histories;
        _foodsNextPageKey = response.nextPageKey;
        _hasMoreFoods = (_foodsNextPageKey?.isNotEmpty ?? false);
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
        _careHistories = response.histories;
        _careNextPageKey = response.nextPageKey;
        _hasMoreCare = (_careNextPageKey?.isNotEmpty ?? false);
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

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('히스토리',
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.deepPurple,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w400),
              tabs: const [
                Tab(text: '패션쇼핑'), 
                Tab(text: '시술/성형'),
                Tab(text: '음식/식자재'),
                Tab(text: '뷰티'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildShoppingTab(),
          _buildCommunityTab(),
          _buildFoodsTab(),
          _buildCareTab(),
        ],
      ),
    );
  }

  Widget _buildShoppingTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialHistories,
      child: _isInitialLoading
          ? _buildSkeleton()
          : _histories.isEmpty
          ? const Center(
        child: Text('히스토리 데이터가 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        controller: _shoppingController,
        itemCount: _histories.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _histories.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return HistoryCard(
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
          ? const Center(
        child: Text('시술커뮤니티 데이터가 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        controller: _communityController,
        itemCount:
        _beautyHistories.length + (_isBeautyLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _beautyHistories.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final history = _beautyHistories[idx];
          return BeautyHistoryCard(
            history: history,
            onTap: () async {
              final updated = await Navigator.push<BeautyHistory>(
                context,
                MaterialPageRoute(
                  builder: (context) => BeautyHistoryDetailScreen(history: history), // ✅ 올바른 화면과 객체 전달
                ),
              );
              if (updated != null) {
                setState(() {
                  final idx = _beautyHistories.indexWhere((h) => h.createdAt == updated.createdAt);
                  if (idx != -1) _beautyHistories[idx] = updated;
                });
              }
            },
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
          ? const Center(
        child: Text('음식/식자재 히스토리가 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        controller: _foodController,
        itemCount: _foodsHistories.length + (_isFoodsLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _foodsHistories.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final history = _foodsHistories[idx];
          return FoodsHistoryCard(
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
          ? const Center(
        child: Text('뷰티 히스토리가 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        controller: _careController,
        itemCount: _careHistories.length + (_isCareLoadingMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _careHistories.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final history = _careHistories[idx];
          return CareHistoryCard(
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
          );
        },
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
