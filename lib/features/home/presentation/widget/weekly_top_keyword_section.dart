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
                TextButton(
                  onPressed: () {
                    debugPrint('WeeklyTopKeywordSection - 전체 패션 상품 버튼 클릭');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllFashionProductScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '전체 패션 상품',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: '카테고리'),
                Tab(text: '쇼핑몰'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: MediaQuery.of(context).size.width <= 320 ? 150 :
                      MediaQuery.of(context).size.width < 360 ? 170 : 150,
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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (i) {
        final rank = startRank + i;
        final keyword = items[i];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2.5 : 5), // 3.5 → 2.5로 더 축소
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 5 : 6, 
                    vertical: isSmallScreen ? 1 : 2
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'TOP $rank',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: isSmallScreen ? 8 : 9, // 더 작은 폰트
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Expanded(
                  child: Text(
                    keyword,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11, // 더 작은 폰트
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, 
                     size: isSmallScreen ? 12 : 14, 
                     color: Colors.grey),
              ],
            ),
          ),
        );
      }),
    );
  }

}
