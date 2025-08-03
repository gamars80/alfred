import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_recipe.dart';
import 'recipe_card.dart';

class WeeklyTopRecipeSectionTheme {
  // 음식다운 따뜻한 색상 팔레트
  static const Color primaryColor = Color(0xFFFF6B35); // 오렌지
  static const Color secondaryColor = Color(0xFFFF8A65); // 연한 오렌지
  static const Color accentColor = Color(0xFFFFD54F); // 노란색
  static const Color warmBackground = Color(0xFFFFF8E1); // 따뜻한 크림색
  static const Color textColor = Color(0xFF424242);
  static const Color subtitleColor = Color(0xFF757575);
  
  // 섹션 스타일
  static const double sectionRadius = 20.0;
  static const double headerRadius = 16.0;
  
  // 섹션 배경 그라데이션
  static const LinearGradient sectionGradient = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 헤더 그라데이션
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
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
      color: Color(0x0AFF6B35),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

class WeeklyTopRecipeSection extends StatefulWidget {
  const WeeklyTopRecipeSection({super.key});

  @override
  State<WeeklyTopRecipeSection> createState() => _WeeklyTopRecipeSectionState();
}

class _WeeklyTopRecipeSectionState extends State<WeeklyTopRecipeSection> {
  final _repo = PopularRepository();
  Future<List<PopularRecipe>>? _futureRecipes;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    if (_futureRecipes == null) {
      _futureRecipes = _repo.fetchWeeklyTopRecipes();
    }
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopRecipeSectionTheme.sectionRadius, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopRecipeSectionTheme.primaryColor,
                  WeeklyTopRecipeSectionTheme.secondaryColor,
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
                  '이번주 조회 Top 10 레시피',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 조회된 음식 레시피',
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
                  WeeklyTopRecipeSectionTheme.primaryColor.withOpacity(0.1),
                  WeeklyTopRecipeSectionTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopRecipeSectionTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF667eea),
              size: 24,
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
      itemBuilder: (_, __) => Container(
        width: 160,
        decoration: BoxDecoration(
          color: WeeklyTopRecipeSectionTheme.warmBackground,
          borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.sectionRadius),
          boxShadow: WeeklyTopRecipeSectionTheme.sectionShadow,
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: WeeklyTopRecipeSectionTheme.secondaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: WeeklyTopRecipeSectionTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: WeeklyTopRecipeSectionTheme.subtitleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WeeklyTopRecipeSectionTheme.warmBackground,
        borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.sectionRadius),
        boxShadow: WeeklyTopRecipeSectionTheme.sectionShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: WeeklyTopRecipeSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.headerRadius),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '레시피를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: WeeklyTopRecipeSectionTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시 후 다시 시도해주세요',
            style: TextStyle(
              fontSize: 14,
              color: WeeklyTopRecipeSectionTheme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WeeklyTopRecipeSectionTheme.warmBackground,
        borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.sectionRadius),
        boxShadow: WeeklyTopRecipeSectionTheme.sectionShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: WeeklyTopRecipeSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.headerRadius),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 인기 레시피가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: WeeklyTopRecipeSectionTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이번주 인기 레시피를 기다려주세요',
            style: TextStyle(
              fontSize: 14,
              color: WeeklyTopRecipeSectionTheme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: WeeklyTopRecipeSectionTheme.sectionGradient,
        borderRadius: BorderRadius.circular(WeeklyTopRecipeSectionTheme.sectionRadius),
        boxShadow: WeeklyTopRecipeSectionTheme.sectionShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 레시피 리스트
          SizedBox(
            height: 260,
            child: FutureBuilder<List<PopularRecipe>>(
              future: _futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      recipe: recipes[index],
                      rank: index + 1,
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: WeeklyTopRecipeSectionTheme.sectionRadius),
        ],
      ),
    );
  }
} 