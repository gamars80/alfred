// lib/features/home/presentation/weekly_top_product_section.dart
import 'package:flutter/material.dart';
import 'package:alfred_clean/features/home/model/popular_product.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_product_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_product_skeleton_card.dart';
import '../../data/popular_repository.dart';

class WeeklyTopProductSectionTheme {
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

class WeeklyTopProductSection extends StatefulWidget {
  const WeeklyTopProductSection({super.key});

  @override
  State<WeeklyTopProductSection> createState() => _WeeklyTopProductSectionState();
}

class _WeeklyTopProductSectionState extends State<WeeklyTopProductSection> {
  final repo = PopularRepository();
  late Future<List<PopularProduct>> futureWeeklyTopProducts;

  @override
  void initState() {
    super.initState();
    futureWeeklyTopProducts = repo.fetchWeeklyTopProducts();
  }

  Widget _buildModernSectionHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopProductSectionTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopProductSectionTheme.primaryGradientStart,
                  WeeklyTopProductSectionTheme.primaryGradientEnd,
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
                  '이번주 조회 Top 10 상품',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 조회된 상품들',
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
                  WeeklyTopProductSectionTheme.primaryGradientStart.withOpacity(0.1),
                  WeeklyTopProductSectionTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopProductSectionTheme.primaryGradientStart.withOpacity(0.1),
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
            WeeklyTopProductSectionTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildModernSectionHeader(),
          
          // 상품 리스트
          SizedBox(
            height: 240,
            child: FutureBuilder<List<PopularProduct>>(
              future: futureWeeklyTopProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, __) => const PopularProductSkeletonCard(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(WeeklyTopProductSectionTheme.cardRadius),
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
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(WeeklyTopProductSectionTheme.cardRadius),
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
                          '이번주 조회 상품이 아직 없습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return PopularProductCard(
                        product: product,
                        rank: index + 1,
                        onTap: () {
                          // TODO: 상세 진입 시 로직 필요 시 구현
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: WeeklyTopProductSectionTheme.sectionSpacing),
        ],
      ),
    );
  }
}
