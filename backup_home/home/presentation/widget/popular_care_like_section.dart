import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_care_like.dart';
import 'care_like_product_card.dart';

class PopularCareLikeSection extends StatefulWidget {
  const PopularCareLikeSection({super.key});

  @override
  State<PopularCareLikeSection> createState() => _PopularCareLikeSectionState();
}

class _PopularCareLikeSectionState extends State<PopularCareLikeSection> {
  final _repo = PopularRepository();
  late Future<List<PopularCareLike>> _futureLikes;

  @override
  void initState() {
    super.initState();
    _futureLikes = _repo.fetchPopularCareLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '인기 찜 Top 10',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<PopularCareLike>>(
            future: _futureLikes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const CareLikeProductCard.skeleton(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('불러오기 실패: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('데이터 없음'));
              }

              final likes = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: likes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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
      ],
    );
  }
} 