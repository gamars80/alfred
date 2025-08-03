import 'package:flutter/material.dart';
import '../../model/popular_beauty_keyword.dart';
import '../../../../features/search/presentation/page/keyword_review_page.dart';

class PopularBeautyKeywordSectionTheme {
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

class PopularBeautyKeywordSectionCard extends StatelessWidget {
  final List<PopularBeautyKeyword> keywords;

  const PopularBeautyKeywordSectionCard({
    super.key,
    required this.keywords,
  });

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, PopularBeautyKeywordSectionTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PopularBeautyKeywordSectionTheme.primaryGradientStart,
                  PopularBeautyKeywordSectionTheme.primaryGradientEnd,
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
                  '이번주 인기 시술 키워드 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 검색된 시술 키워드',
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
                  PopularBeautyKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
                  PopularBeautyKeywordSectionTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PopularBeautyKeywordSectionTheme.primaryGradientStart.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PopularBeautyKeywordSectionTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 키워드 리스트
          SizedBox(
            height: 35,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: keywords.length,
              itemBuilder: (context, index) {
                final keyword = keywords[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _KeywordCard(
                    rank: index + 1,
                    keyword: keyword,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: PopularBeautyKeywordSectionTheme.sectionSpacing),
        ],
      ),
    );
  }
}

class _KeywordCard extends StatelessWidget {
  final int rank;
  final PopularBeautyKeyword keyword;

  const _KeywordCard({
    required this.rank,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KeywordReviewPage(
              keyword: keyword.keyword,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                keyword.keyword,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 