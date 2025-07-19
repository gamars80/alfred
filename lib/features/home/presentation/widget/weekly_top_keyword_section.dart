import 'package:flutter/material.dart';
import '../../../search/presentation/category_product_screen.dart';
import '../../../search/presentation/source_product_screen.dart';
import '../../../search/presentation/all_fashion_product_screen.dart';
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
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    debugPrint('WeeklyTopKeywordSection - 전체 패션 상품 버튼 클릭');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllFashionProductScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 22),
                  label: const Text(
                    '전체 패션 상품',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.deepPurple),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(text: '카테고리'),
                Tab(text: '쇼핑몰'),
              ],
            ),
            const SizedBox(height: 12),
            _buildDynamicHeightTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordList(Future<List<String>> futureKeywords, {required int startRank, required int maxVisible, required double rowHeight}) {
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

        final keywords = snapshot.data ?? <String>[];
        if (keywords.length <= maxVisible) {
          // fit하게
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(keywords.length, (i) {
              final rank = startRank + i;
              final keyword = keywords[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    final isCategory = _tabController.index == 0;
                    debugPrint('WeeklyTopKeywordSection - Navigating to ${isCategory ? "CategoryProductScreen" : "SourceProductScreen"} with ${isCategory ? "category" : "source"}: $keyword');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _tabController.index == 0
                            ? CategoryProductScreen(category: keyword)
                            : SourceProductScreen(source: keyword),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'TOP $rank',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          keyword,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          );
        } else {
          // 5개 이상이면 스크롤
          return SizedBox(
            height: maxVisible * rowHeight,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: keywords.length,
              itemBuilder: (context, i) {
                final rank = startRank + i;
                final keyword = keywords[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    onTap: () {
                      final isCategory = _tabController.index == 0;
                      debugPrint('WeeklyTopKeywordSection - Navigating to ${isCategory ? "CategoryProductScreen" : "SourceProductScreen"} with ${isCategory ? "category" : "source"}: $keyword');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _tabController.index == 0
                              ? CategoryProductScreen(category: keyword)
                              : SourceProductScreen(source: keyword),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'TOP $rank',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            keyword,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildDynamicHeightTabBarView() {
    // 키워드 개수에 따라 동적으로 높이 계산
    return FutureBuilder<List<List<String>>>(
      future: Future.wait([
        futureCategoryKeywords,
        futureMallKeywords,
      ]),
      builder: (context, snapshot) {
        int maxCount = 10;
        if (snapshot.hasData) {
          final lists = snapshot.data as List<List<String>>;
          maxCount = lists.map((e) => e.length).fold(0, (a, b) => a > b ? a : b);
          if (maxCount > 10) maxCount = 10;
          if (maxCount < 1) maxCount = 1;
        }
        final int maxVisible = 5;
        final double rowHeight = 36;
        final double minHeight = 48;
        final double height = (maxCount > maxVisible ? maxVisible : maxCount) * rowHeight;
        return SizedBox(
          height: height < minHeight ? minHeight : height,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKeywordList(futureCategoryKeywords, startRank: 1, maxVisible: maxVisible, rowHeight: rowHeight),
              _buildKeywordList(futureMallKeywords, startRank: 1, maxVisible: maxVisible, rowHeight: rowHeight),
            ],
          ),
        );
      },
    );
  }

}
