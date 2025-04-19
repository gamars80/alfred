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

  String parseGptCondition(String condition) {
    if (condition.startsWith("SearchCondition(") && condition.endsWith(")")) {
      String inner =
      condition.substring("SearchCondition(".length, condition.length - 1);
      List<String> parts = inner.split(',');
      List<String> values = [];
      for (var part in parts) {
        List<String> kv = part.split('=');
        if (kv.length == 2) {
          String value = kv[1].trim();
          if (value != "null" && value.isNotEmpty) {
            values.add(value);
          }
        }
      }
      return values.join(', ');
    }
    return condition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialHistories,
        child: _histories.isEmpty
            ? const Center(child: CircularProgressIndicator())
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

            final history = _histories[index];
            final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(history.createdAt),
            );
            final conditionParsed = parseGptCondition(history.gptCondition);

            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
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
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Colors.deepPurple),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conditionParsed,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6A1B9A), // 딥 퍼플 포인트
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
