import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/history_repository.dart';
import '../model/recommendation_history.dart';
import 'history_detail_screen.dart';

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
    _loadInitialHistories();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
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
      setState(() {
        _isInitialLoading = false;
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
        _hasMore = (_nextPageKey != null && _nextPageKey!.isNotEmpty);
      });
    } catch (e) {
      debugPrint('Error loading more histories: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  List<String> extractTags(String gptCondition) {
    final tags = <String>[];

    final pattern = RegExp(r'(\w+)=((\[[^\]]*\])|[^,)]*)');
    final matches = pattern.allMatches(gptCondition);

    for (final match in matches) {
      final key = match.group(1);
      final rawValue = match.group(2)?.trim();

      if (rawValue == null || rawValue == 'null' || rawValue.isEmpty) continue;

      if (rawValue.startsWith('[') && rawValue.endsWith(']')) {
        // 리스트 항목 처리: [벨트, 청바지]
        final innerItems = rawValue.substring(1, rawValue.length - 1).split(',');
        for (var item in innerItems) {
          final tag = item.trim();
          if (tag.isNotEmpty) tags.add('#$tag');
        }
      } else {
        tags.add('#$rawValue');
      }
    }

    return tags;
  }



  Widget buildSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
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

  Widget buildHistoryCard(RecommendationHistory history, int index) {
    final tags = extractTags(history.gptCondition);
    final formattedDate =
    DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(history.createdAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push<RecommendationHistory>(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryDetailScreen(history: history),
            ),
          ).then((updatedHistory) {
            if (updatedHistory != null) {
              setState(() {
                _histories[index] = updatedHistory;
              });
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // 카드 간 여백 줄임
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // 패딩 축소
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.query,
                  style: const TextStyle(
                    fontSize: 14.5, // 텍스트 작게
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12, // 태그 작게
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(history.createdAt),
                      ),
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('히스토리')),
      body: RefreshIndicator(
        onRefresh: _loadInitialHistories,
        child: _isInitialLoading
            ? buildSkeleton()
            : (_histories.isEmpty
            ? const Center(
          child: Text(
            '히스토리 데이터가 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: _histories.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _histories.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return buildHistoryCard(_histories[index], index);
          },
        )),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
