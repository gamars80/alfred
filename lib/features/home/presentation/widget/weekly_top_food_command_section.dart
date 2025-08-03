import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_food_ingredient.dart';
import '../../../search/presentation/food_ingredient_product_screen.dart';
import '../../../search/presentation/food_ingredient_recipe_screen.dart';

class WeeklyTopFoodCommandSectionTheme {
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

class WeeklyTopFoodCommandSection extends StatefulWidget {
  const WeeklyTopFoodCommandSection({super.key});

  @override
  State<WeeklyTopFoodCommandSection> createState() => _WeeklyTopFoodCommandSectionState();
}

class _WeeklyTopFoodCommandSectionState extends State<WeeklyTopFoodCommandSection> {
  final _repo = PopularRepository();
  Future<List<PopularFoodIngredient>>? _futureIngredients;
  Future<List<PopularFoodIngredient>>? _futureRecipeIngredients;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() {
    if (_futureIngredients == null) {
      _futureIngredients = _repo.fetchWeeklyTopFoodIngredients();
    }
    if (_futureRecipeIngredients == null) {
      _futureRecipeIngredients = _repo.fetchWeeklyTopFoodRecipeIngredients();
    }
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, WeeklyTopFoodCommandSectionTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopFoodCommandSectionTheme.primaryGradientStart,
                  WeeklyTopFoodCommandSectionTheme.primaryGradientEnd,
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
                  '이번주 인기 음식 명령어 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 사용된 음식 관련 명령어',
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
                  WeeklyTopFoodCommandSectionTheme.primaryGradientStart.withOpacity(0.1),
                  WeeklyTopFoodCommandSectionTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: WeeklyTopFoodCommandSectionTheme.primaryGradientStart.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        children: [
          _buildTabButton('상품', 0),
          const SizedBox(width: 12),
          _buildTabButton('레시피', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    WeeklyTopFoodCommandSectionTheme.primaryGradientStart,
                    WeeklyTopFoodCommandSectionTheme.primaryGradientEnd,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? WeeklyTopFoodCommandSectionTheme.primaryGradientStart.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String ingredient, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeeklyTopFoodCommandSectionTheme.primaryGradientStart,
                  WeeklyTopFoodCommandSectionTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Icon(
            Icons.restaurant_rounded,
            size: 16,
            color: WeeklyTopFoodCommandSectionTheme.primaryGradientStart,
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
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopFoodCommandSectionTheme.cardRadius),
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
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopFoodCommandSectionTheme.cardRadius),
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
                  '이번주 인기 음식 명령어가 아직 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final ingredients = snapshot.data!;
        return Container(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final rank = index + 1;
              final ingredient = ingredients[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodIngredientProductScreen(
                        ingredient: ingredient.ingredient,
                      ),
                    ),
                  );
                },
                child: _buildIngredientChip(ingredient.ingredient, rank),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeTab() {
    return FutureBuilder<List<PopularFoodIngredient>>(
      future: _futureRecipeIngredients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopFoodCommandSectionTheme.cardRadius),
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
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(WeeklyTopFoodCommandSectionTheme.cardRadius),
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
                  '이번주 인기 레시피 명령어가 아직 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final ingredients = snapshot.data!;
        return Container(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final rank = index + 1;
              final ingredient = ingredients[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodIngredientRecipeScreen(
                        ingredient: ingredient.ingredient,
                      ),
                    ),
                  );
                },
                child: _buildIngredientChip(ingredient.ingredient, rank),
              );
            },
          ),
        );
      },
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
            WeeklyTopFoodCommandSectionTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildModernHeader(),
          _buildModernTabBar(),
          
          // 콘텐츠 영역
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _selectedIndex == 0 ? _buildProductTab() : _buildRecipeTab(),
          ),
          
          const SizedBox(height: WeeklyTopFoodCommandSectionTheme.sectionSpacing),
        ],
      ),
    );
  }
} 