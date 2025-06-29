import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_care_product.dart';
import 'care_product_card.dart';

class WeeklyTopCareProductSection extends StatefulWidget {
  const WeeklyTopCareProductSection({super.key});

  @override
  State<WeeklyTopCareProductSection> createState() => _WeeklyTopCareProductSectionState();
}

class _WeeklyTopCareProductSectionState extends State<WeeklyTopCareProductSection> {
  final _repo = PopularRepository();
  late Future<List<PopularCareProduct>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _repo.fetchWeeklyTopCareProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '이번주 조회 Top 10 상품',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<PopularCareProduct>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const CareProductCard.skeleton(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('불러오기 실패: ${snapshot.error}'));
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
                  return CareProductCard(
                    product: product,
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
      ],
    );
  }
} 