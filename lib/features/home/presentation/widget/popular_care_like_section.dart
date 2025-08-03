import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_care_like.dart';
import 'care_like_product_card.dart';

class PopularCareLikeSectionTheme {
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

class PopularCareLikeSection extends StatefulWidget {
  const PopularCareLikeSection({super.key});

  @override
  State<PopularCareLikeSection> createState() => _PopularCareLikeSectionState();
}

class _PopularCareLikeSectionState extends State<PopularCareLikeSection> {
  final _repo = PopularRepository();
  Future<List<PopularCareLike>>? _futureLikes;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  void _loadLikes() {
    if (_futureLikes == null) {
      _futureLikes = _repo.fetchPopularCareLikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PopularCareLikeSectionTheme.sectionGradient,
        borderRadius: BorderRadius.circular(PopularCareLikeSectionTheme.sectionRadius),
        boxShadow: PopularCareLikeSectionTheme.sectionShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 찜 상품 리스트
          SizedBox(
            height: 240,
            child: FutureBuilder<List<PopularCareLike>>(
              future: _futureLikes,
              builder: (context, snapshot) {
                if (_futureLikes == null) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                
                final likes = snapshot.data ?? [];
                if (likes.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: likes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final like = likes[index];
                    return CareLikeProductCard(
                      product: like,
                      rank: index + 1,
                      onTap: () {
                        // TODO: 상세 진입 등 필요시 구현
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: PopularCareLikeSectionTheme.sectionRadius),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, PopularCareLikeSectionTheme.sectionRadius, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: PopularCareLikeSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '인기 찜 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PopularCareLikeSectionTheme.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많은 찜을 받은 뷰티 상품',
                  style: TextStyle(
                    fontSize: 14,
                    color: PopularCareLikeSectionTheme.subtitleColor,
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
                  PopularCareLikeSectionTheme.primaryColor.withOpacity(0.1),
                  PopularCareLikeSectionTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(PopularCareLikeSectionTheme.headerRadius),
              boxShadow: [
                BoxShadow(
                  color: PopularCareLikeSectionTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 24,
              color: PopularCareLikeSectionTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (_, __) => const CareLikeProductCard.skeleton(),
    );
  }

  Widget _buildErrorState() {
    return const Center(child: Text('불러오기 실패'));
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('데이터 없음'));
  }
} 