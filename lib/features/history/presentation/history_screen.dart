import 'package:flutter/material.dart';
import 'package:alfred_clean/features/history/data/history_repository.dart';
import 'package:alfred_clean/features/history/model/recommendation_history.dart';
import 'package:alfred_clean/features/history/presentation/widget/history_card.dart';
import 'package:alfred_clean/features/history/presentation/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository repository = HistoryRepository();
  final ScrollController _scrollController = ScrollController();

  List<RecommendationHistory> _histories = [];
  String? _nextPageKey;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    _loadInitialHistories();
  }

  Future<void> _loadInitialHistories() async {
    try {
      final response = await repository.fetchHistories(limit: _limit);
      setState(() {
        _histories = response.histories;
        _nextPageKey = response.nextPageKey;
        _hasMore = (_nextPageKey != null && _nextPageKey!.isNotEmpty);
      });
    } catch (e) {
      debugPrint('Error loading histories: $e');
    } finally {
      setState(() => _isInitialLoading = false);
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
        _hasMore = (_nextPageKey != null && _nextPageKey!.isNotEmpty);
      });
    } catch (e) {
      debugPrint('Error loading more histories: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9), // 전체 배경을 따뜻한 연회색으로
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: const Text(
            '히스토리',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor, // 선택된 탭은 진한 앱 메인컬러
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white, // 선택 탭 텍스트는 흰색
                unselectedLabelColor: Colors.grey, // 비선택 탭은 회색
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: '쇼핑'),
                  Tab(text: '시술커뮤니티'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildShoppingTab(),
            _buildCommunityTab(),
          ],
        ),
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
        child: Text(
          '히스토리 데이터가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
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
                  builder: (_) => HistoryDetailScreen(history: _histories[idx]),
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
    return const Center(
      child: Text(
        '시술커뮤니티 콘텐츠 준비 중',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}