import 'package:flutter/material.dart';
import '../../../search/presentation/category_product_screen.dart';
import '../../../search/presentation/source_product_screen.dart';
import '../../../search/presentation/all_fashion_product_screen.dart';
import '../../data/popular_repository.dart';
import '../../../search/presentation/review_list_screen.dart';

class WeeklyTopKeywordSectionTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 배경 색상
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardBackgroundColor = Colors.white;
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double sectionSpacing = 24.0;
}

class WeeklyTopKeywordSection extends StatefulWidget {
  const WeeklyTopKeywordSection({super.key});

  @override
  State<WeeklyTopKeywordSection> createState() => _WeeklyTopKeywordSectionState();
}

class _WeeklyTopKeywordSectionState extends State<WeeklyTopKeywordSection> with TickerProviderStateMixin {
  late TabController _tabController;
  final repo = PopularRepository();
  Future<List<String>>? futureCategoryKeywords;
  Future<List<String>>? futureMallKeywords;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadKeywords();
  }

  void _loadKeywords() {
    if (futureCategoryKeywords == null) {
      futureCategoryKeywords = repo.fetchWeeklyTopCategories();
    }
    if (futureMallKeywords == null) {
      futureMallKeywords = repo.fetchWeeklyTopSources();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopKeywordSectionTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopKeywordSectionTheme.primaryGradientStart,
                  WeeklyTopKeywordSectionTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번주 인기 키워드',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 검색된 키워드',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
                  WeeklyTopKeywordSectionTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTabButton('카테고리', 0),
          const SizedBox(width: 12),
          _buildTabButton('쇼핑몰', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    WeeklyTopKeywordSectionTheme.primaryGradientStart,
                    WeeklyTopKeywordSectionTheme.primaryGradientEnd,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordChip(String keyword, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopKeywordSectionTheme.primaryGradientStart,
                  WeeklyTopKeywordSectionTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              keyword,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Icon(
            Icons.trending_up_rounded,
            size: 16,
            color: WeeklyTopKeywordSectionTheme.primaryGradientStart,
          ),
        ],
      ),
    );
  }

  Widget _buildAllFashionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  debugPrint('WeeklyTopKeywordSection - 전체 패션 상품 버튼 클릭');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllFashionProductScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
                        WeeklyTopKeywordSectionTheme.primaryGradientEnd.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체 패션 보기',
                        style: TextStyle(
                          color: WeeklyTopKeywordSectionTheme.primaryGradientStart,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: WeeklyTopKeywordSectionTheme.primaryGradientStart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  debugPrint('WeeklyTopKeywordSection - 전체 패션 리뷰 버튼 클릭');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
                        WeeklyTopKeywordSectionTheme.primaryGradientEnd.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: WeeklyTopKeywordSectionTheme.primaryGradientStart.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reviews_rounded,
                        size: 16,
                        color: WeeklyTopKeywordSectionTheme.primaryGradientStart,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '전체 리뷰',
                        style: TextStyle(
                          color: WeeklyTopKeywordSectionTheme.primaryGradientStart,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordList(Future<List<String>> futureKeywords, {required int startRank, required int maxVisible, required double rowHeight}) {
    return FutureBuilder<List<String>>(
      future: futureKeywords,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopKeywordSectionTheme.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '불러오기 실패',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopKeywordSectionTheme.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '데이터가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '이번주 인기 키워드가 아직 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final keywords = snapshot.data ?? <String>[];
        if (keywords.length <= maxVisible) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(keywords.length, (i) {
              final rank = startRank + i;
              final keyword = keywords[i];
              return GestureDetector(
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
                child: _buildKeywordChip(keyword, rank),
              );
            }),
          );
        } else {
          return SizedBox(
            height: maxVisible * rowHeight,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: keywords.length,
              itemBuilder: (context, i) {
                final rank = startRank + i;
                final keyword = keywords[i];
                return GestureDetector(
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
                  child: _buildKeywordChip(keyword, rank),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildDynamicHeightTabBarView() {
    return FutureBuilder<List<List<String>>>(
      future: Future.wait([
        futureCategoryKeywords!,
        futureMallKeywords!,
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
        final double rowHeight = 45;
        final double minHeight = 48;
        final double height = (maxCount > maxVisible ? maxVisible : maxCount) * rowHeight;
        return SizedBox(
          height: height < minHeight ? minHeight : height,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKeywordList(futureCategoryKeywords!, startRank: 1, maxVisible: maxVisible, rowHeight: rowHeight),
              _buildKeywordList(futureMallKeywords!, startRank: 1, maxVisible: maxVisible, rowHeight: rowHeight),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WeeklyTopKeywordSectionTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildModernHeader(),
          _buildModernTabBar(),
          
          // 키워드 리스트
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDynamicHeightTabBarView(),
          ),
          
          _buildAllFashionButton(),
          const SizedBox(height: WeeklyTopKeywordSectionTheme.sectionSpacing),
        ],
      ),
    );
  }
}
