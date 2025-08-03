import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_care_keyword.dart';
import '../../../search/presentation/care_keyword_product_screen.dart';

class WeeklyTopCareKeywordSectionTheme {
  // 뷰티다운 우아한 색상 팔레트
  static const Color primaryColor = Color(0xFFE91E63); // 핑크
  static const Color secondaryColor = Color(0xFFF06292); // 연한 핑크
  static const Color accentColor = Color(0xFFFFC0CB); // 라이트 핑크
  static const Color elegantBackground = Color(0xFFFFF5F7); // 우아한 크림색
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);
  
  // 섹션 스타일
  static const double sectionRadius = 20.0;
  static const double headerRadius = 16.0;
  
  // 섹션 배경 그라데이션
  static const LinearGradient sectionGradient = LinearGradient(
    colors: [Color(0xFFFFF5F7), Color(0xFFFFF0F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 헤더 그라데이션
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 그림자 효과
  static const List<BoxShadow> sectionShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0AE91E63),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

class WeeklyTopCareKeywordSection extends StatefulWidget {
  const WeeklyTopCareKeywordSection({super.key});

  @override
  State<WeeklyTopCareKeywordSection> createState() => _WeeklyTopCareKeywordSectionState();
}

class _WeeklyTopCareKeywordSectionState extends State<WeeklyTopCareKeywordSection> {
  final _repo = PopularRepository();
  Future<List<PopularCareKeyword>>? _futureKeywords;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  void _loadKeywords() {
    if (_futureKeywords == null) {
      _futureKeywords = _repo.fetchWeeklyTopCareKeywords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: WeeklyTopCareKeywordSectionTheme.sectionGradient,
        borderRadius: BorderRadius.circular(WeeklyTopCareKeywordSectionTheme.sectionRadius),
        boxShadow: WeeklyTopCareKeywordSectionTheme.sectionShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildModernHeader(),
          SizedBox(
            height: 140,
            child: _buildKeywordList(),
          ),
          const SizedBox(height: WeeklyTopCareKeywordSectionTheme.sectionRadius),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopCareKeywordSectionTheme.sectionRadius, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: WeeklyTopCareKeywordSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이번주 인기 키워드 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: WeeklyTopCareKeywordSectionTheme.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 검색된 뷰티케어 키워드',
                  style: TextStyle(
                    fontSize: 14,
                    color: WeeklyTopCareKeywordSectionTheme.subtitleColor,
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
                  WeeklyTopCareKeywordSectionTheme.primaryColor.withOpacity(0.1),
                  WeeklyTopCareKeywordSectionTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(WeeklyTopCareKeywordSectionTheme.headerRadius),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopCareKeywordSectionTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.spa_rounded,
              size: 24,
              color: WeeklyTopCareKeywordSectionTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordList() {
    if (_futureKeywords == null) {
      return _buildSkeletonLoading();
    }
    return FutureBuilder<List<PopularCareKeyword>>(
      future: _futureKeywords,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonLoading();
        } else if (snapshot.hasError) {
          return _buildErrorState();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final keywords = snapshot.data!;
        return _buildKeywordColumns(keywords);
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SkeletonItem(
            height: 30,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        '데이터를 불러오는데 실패했습니다.',
        style: TextStyle(color: WeeklyTopCareKeywordSectionTheme.textColor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        '데이터가 없습니다.',
        style: TextStyle(color: WeeklyTopCareKeywordSectionTheme.textColor),
      ),
    );
  }

  Widget _buildKeywordColumns(List<PopularCareKeyword> keywords) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: keywords.length,
      itemBuilder: (context, index) {
        final rank = index + 1;
        final keyword = keywords[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CareKeywordProductScreen(
                  keyword: keyword.keyword,
                ),
              ),
            );
          },
          child: _buildKeywordChip(keyword.keyword, rank),
        );
      },
    );
  }

  Widget _buildKeywordChip(String keyword, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              gradient: WeeklyTopCareKeywordSectionTheme.headerGradient,
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
            Icons.spa_rounded,
            size: 16,
            color: WeeklyTopCareKeywordSectionTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class SkeletonItem extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;

  const SkeletonItem({
    super.key,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: WeeklyTopCareKeywordSectionTheme.secondaryColor.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
    );
  }
} 