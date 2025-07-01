// lib/features/home/presentation/popular_section.dart
import 'package:alfred_clean/features/home/presentation/widget/popular_product_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_product_skeleton_card.dart';
import 'package:flutter/material.dart';
import '../data/popular_repository.dart';
import '../model/popular_product.dart';


class PopularSection extends StatefulWidget {
  const PopularSection({super.key});

  @override
  State<PopularSection> createState() => _PopularSectionState();
}

class _PopularSectionState extends State<PopularSection> with SingleTickerProviderStateMixin {
  final repo = PopularRepository();
  late Future<List<PopularProduct>> futurePopular;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futurePopular = repo.fetchPopularProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: const [
              Text(
                '인기 찜 Top 10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 상품 리스트
        FutureBuilder<List<PopularProduct>>(
          future: futurePopular,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const PopularProductSkeletonCard(),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('불러오기 실패: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('데이터 없음'));
            }

            final products = snapshot.data!;
            return SizedBox(
              height: 230,
              child: ListView.separated(
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
                      // TODO: 상세 진입
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
