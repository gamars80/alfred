import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_care_product.dart';
import 'care_product_card.dart';
import '../../../search/presentation/care_keyword_product_screen.dart';

class WeeklyTopCareProductSectionTheme {
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

class WeeklyTopCareProductSection extends StatefulWidget {
  const WeeklyTopCareProductSection({super.key});

  @override
  State<WeeklyTopCareProductSection> createState() => _WeeklyTopCareProductSectionState();
}

class _WeeklyTopCareProductSectionState extends State<WeeklyTopCareProductSection> {
  final _repo = PopularRepository();
  Future<List<PopularCareProduct>>? _futureProducts;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (_futureProducts == null) {
      _futureProducts = _repo.fetchWeeklyTopCareProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: WeeklyTopCareProductSectionTheme.sectionGradient,
        borderRadius: BorderRadius.circular(WeeklyTopCareProductSectionTheme.sectionRadius),
        boxShadow: WeeklyTopCareProductSectionTheme.sectionShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 상품 리스트
          SizedBox(
            height: 220,
            child: FutureBuilder<List<PopularCareProduct>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (_futureProducts == null) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return CareProductCard(
                      product: product,
                      rank: index + 1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CareKeywordProductScreen(
                              keyword: product.keyword,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: WeeklyTopCareProductSectionTheme.sectionRadius),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopCareProductSectionTheme.sectionRadius, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: WeeklyTopCareProductSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이번주 조회 Top 10 상품',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: WeeklyTopCareProductSectionTheme.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 조회된 뷰티케어 상품',
                  style: TextStyle(
                    fontSize: 14,
                    color: WeeklyTopCareProductSectionTheme.subtitleColor,
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
                  WeeklyTopCareProductSectionTheme.primaryColor.withOpacity(0.1),
                  WeeklyTopCareProductSectionTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(WeeklyTopCareProductSectionTheme.headerRadius),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopCareProductSectionTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 24,
              color: WeeklyTopCareProductSectionTheme.primaryColor,
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
      itemBuilder: (_, __) => const CareProductCard.skeleton(),
    );
  }

  Widget _buildErrorState() {
    return const Center(child: Text('불러오기 실패'));
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('데이터 없음'));
  }
} 