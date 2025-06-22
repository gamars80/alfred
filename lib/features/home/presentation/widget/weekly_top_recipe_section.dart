import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_recipe.dart';
import 'recipe_card.dart';

class WeeklyTopRecipeSection extends StatefulWidget {
  const WeeklyTopRecipeSection({super.key});

  @override
  State<WeeklyTopRecipeSection> createState() => _WeeklyTopRecipeSectionState();
}

class _WeeklyTopRecipeSectionState extends State<WeeklyTopRecipeSection> {
  final _repo = PopularRepository();
  late Future<List<PopularRecipe>> _futureRecipes;

  @override
  void initState() {
    super.initState();
    _futureRecipes = _repo.fetchWeeklyTopRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '이번주 조회 Top 10 레시피',
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
          child: FutureBuilder<List<PopularRecipe>>(
            future: _futureRecipes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => RecipeCardSkeleton.skeleton(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('불러오기 실패: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('데이터 없음'));
              }

              final recipes = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    rank: index + 1,
                    onTap: () {
                      // TODO: 레시피 상세 진입 등 필요시 구현
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