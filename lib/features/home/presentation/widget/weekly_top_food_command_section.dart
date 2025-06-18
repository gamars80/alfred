import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_food_ingredient.dart';

class WeeklyTopFoodCommandSection extends StatefulWidget {
  const WeeklyTopFoodCommandSection({super.key});

  @override
  State<WeeklyTopFoodCommandSection> createState() => _WeeklyTopFoodCommandSectionState();
}

class _WeeklyTopFoodCommandSectionState extends State<WeeklyTopFoodCommandSection> {
  final _repo = PopularRepository();
  late Future<List<PopularFoodIngredient>> _futureIngredients;

  @override
  void initState() {
    super.initState();
    _futureIngredients = _repo.fetchWeeklyTopFoodIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이번주 인기 명령어 Top 10',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<PopularFoodIngredient>>(
              future: _futureIngredients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('불러오기 실패: ${snapshot.error}', 
                    style: const TextStyle(color: Colors.black87));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('데이터가 없습니다', 
                    style: const TextStyle(color: Colors.black87));
                }

                final ingredients = snapshot.data!;
                // 각 항목의 높이 (패딩 포함)
                const itemHeight = 30.0;
                // 전체 높이 계산 (데이터 개수에 따라)
                final totalHeight = (ingredients.length / 2).ceil() * itemHeight;

                return SizedBox(
                  height: totalHeight,
                  child: _buildCommandList(ingredients),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandList(List<PopularFoodIngredient> ingredients) {
    final List<PopularFoodIngredient> left = [];
    final List<PopularFoodIngredient> right = [];

    // 데이터를 좌우로 번갈아가며 분배
    for (int i = 0; i < ingredients.length; i++) {
      if (i % 2 == 0) {
        left.add(ingredients[i]);
      } else {
        right.add(ingredients[i]);
      }
    }

    return Row(
      children: [
        Expanded(child: _buildRankColumn(left, 1)),
        const SizedBox(width: 24),
        Expanded(child: _buildRankColumn(right, 2)),
      ],
    );
  }

  Widget _buildRankColumn(List<PopularFoodIngredient> items, int startRank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (i) {
        // 왼쪽 컬럼은 1,3,5,7,9, 오른쪽 컬럼은 2,4,6,8,10
        final rank = startRank + (i * 2);
        final ingredient = items[i];

        return SizedBox(
          height: 30, // 각 항목의 고정 높이
          child: InkWell(
            onTap: () {
              // TODO: 명령어 실행 로직 구현
              debugPrint('WeeklyTopFoodCommandSection - Command tapped: ${ingredient.ingredient}');
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'TOP $rank',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ingredient.ingredient,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      }),
    );
  }
} 