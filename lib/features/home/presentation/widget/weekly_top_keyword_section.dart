import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';


class WeeklyTopKeywordSection extends StatefulWidget {
  const WeeklyTopKeywordSection({super.key});

  @override
  State<WeeklyTopKeywordSection> createState() => _WeeklyTopKeywordSectionState();
}

class _WeeklyTopKeywordSectionState extends State<WeeklyTopKeywordSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final repo = PopularRepository();
  late Future<List<String>> futureCategoryKeywords;
  late Future<List<String>> futureMallKeywords;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureCategoryKeywords = repo.fetchWeeklyTopCategories();
    futureMallKeywords = repo.fetchWeeklyTopSources(); // 구현 필요
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: '카테고리 랭킹'),
                Tab(text: '쇼핑몰 랭킹'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120, // 원하는 높이 설정
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildKeywordList(futureCategoryKeywords, startRank: 1),
                  _buildKeywordList(futureMallKeywords, startRank: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordList(Future<List<String>> futureKeywords, {required int startRank}) {
    return FutureBuilder<List<String>>(
      future: futureKeywords,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('불러오기 실패: ${snapshot.error}', style: const TextStyle(color: Colors.black87));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('키워드가 없습니다', style: TextStyle(color: Colors.black87));
        }

        final keywords = snapshot.data!;
        final left = keywords.take(5).toList();
        final right = keywords.skip(5).toList();

        return Row(
          children: [
            Expanded(child: _buildRankColumn(left, startRank)),
            const SizedBox(width: 24),
            Expanded(child: _buildRankColumn(right, startRank + 5)),
          ],
        );
      },
    );
  }

  Widget _buildRankColumn(List<String> items, int startRank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Text(
                '${startRank + i}.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items[i],
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
