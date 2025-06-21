import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_food_ingredient.dart';
import '../../../search/presentation/food_ingredient_product_screen.dart';
import '../../../search/presentation/food_ingredient_recipe_screen.dart';

class WeeklyTopFoodCommandSection extends StatefulWidget {
  const WeeklyTopFoodCommandSection({super.key});

  @override
  State<WeeklyTopFoodCommandSection> createState() => _WeeklyTopFoodCommandSectionState();
}

class _WeeklyTopFoodCommandSectionState extends State<WeeklyTopFoodCommandSection> {
  final _repo = PopularRepository();
  late Future<List<PopularFoodIngredient>> _futureIngredients;
  late Future<List<PopularFoodIngredient>> _futureRecipeIngredients;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureIngredients = _repo.fetchWeeklyTopFoodIngredients();
    _futureRecipeIngredients = _repo.fetchWeeklyTopFoodRecipeIngredients();
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
            // 심플한 텍스트 탭
            Row(
              children: [
                Expanded(
                  child: _buildTextTab(
                    text: '상품',
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                Expanded(
                  child: _buildTextTab(
                    text: '레시피',
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 콘텐츠 영역
            _selectedIndex == 0 ? _buildProductTab() : _buildRecipeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            color: isSelected ? Colors.black87 : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab() {
    return FutureBuilder<List<PopularFoodIngredient>>(
      future: _futureIngredients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('불러오기 실패: ${snapshot.error}', 
            style: const TextStyle(color: Colors.black87));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('데이터가 없습니다', 
            style: TextStyle(color: Colors.black87));
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
    );
  }

  Widget _buildRecipeTab() {
    return FutureBuilder<List<PopularFoodIngredient>>(
      future: _futureRecipeIngredients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('불러오기 실패: ${snapshot.error}', 
            style: const TextStyle(color: Colors.black87));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('데이터가 없습니다', 
            style: TextStyle(color: Colors.black87));
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
              if (_selectedIndex == 0) {
                // 상품 탭
                debugPrint('WeeklyTopFoodCommandSection - Navigating to FoodIngredientProductScreen with ingredient: ${ingredient.ingredient}');
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodIngredientProductScreen(
                      ingredient: ingredient.ingredient,
                    ),
                  ),
                );
              } else {
                // 레시피 탭
                debugPrint('WeeklyTopFoodCommandSection - Navigating to FoodIngredientRecipeScreen with ingredient: ${ingredient.ingredient}');
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodIngredientRecipeScreen(
                      ingredient: ingredient.ingredient,
                    ),
                  ),
                );
              }
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