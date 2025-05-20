// lib/features/home/presentation/weekly_top_product_section.dart
import 'package:flutter/material.dart';
import 'package:alfred_clean/features/home/model/popular_product.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_product_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_product_skeleton_card.dart';
import '../../data/popular_repository.dart';


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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: const [
              Text(
                '이번주 조회 Top 10 상품',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<PopularProduct>>(
            future: futureWeeklyTopProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const PopularProductSkeletonCard(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('불러오기 실패: \${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('데이터 없음'));
              }

              final products = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
