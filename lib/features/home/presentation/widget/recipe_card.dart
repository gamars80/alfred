import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/popular_recipe.dart';

class RecipeCardTheme {
  // 음식다운 따뜻한 색상 팔레트
  static const Color primaryColor = Color(0xFFFF6B35); // 오렌지
  static const Color secondaryColor = Color(0xFFFF8A65); // 연한 오렌지
  static const Color accentColor = Color(0xFFFFD54F); // 노란색
  static const Color warmBackground = Color(0xFFFFF8E1); // 따뜻한 크림색
  static const Color textColor = Color(0xFF424242);
  static const Color subtitleColor = Color(0xFF757575);
  
  // 카드 스타일
  static const double cardRadius = 16.0;
  static const double imageRadius = 12.0;
  static const double badgeRadius = 20.0;
  
  // 그림자 효과
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0AFF6B35),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  // 랭킹 배지 그라데이션
  static const LinearGradient rankGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 소스 배지 그라데이션
  static const LinearGradient sourceGradient = LinearGradient(
    colors: [Color(0xFFFF8A65), Color(0xFFFFAB91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class RecipeCard extends StatelessWidget {
  final PopularRecipe recipe;
  final int rank;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.rank,
    this.onTap,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(recipe.detailLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRankBadge() {
    Color badgeColor;
    Color textColor;
    
    if (rank <= 3) {
      badgeColor = RecipeCardTheme.accentColor;
      textColor = Colors.white;
    } else {
      badgeColor = RecipeCardTheme.primaryColor;
      textColor = Colors.white;
    }
    
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: RecipeCardTheme.rankGradient,
        borderRadius: BorderRadius.circular(RecipeCardTheme.badgeRadius),
        boxShadow: [
          BoxShadow(
            color: RecipeCardTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    if (recipe.source == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: RecipeCardTheme.sourceGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: RecipeCardTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            recipe.source!,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 220,
        decoration: BoxDecoration(
          color: RecipeCardTheme.warmBackground,
          borderRadius: BorderRadius.circular(RecipeCardTheme.cardRadius),
          boxShadow: RecipeCardTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지와 순위, 출처
            Stack(
              children: [
                GestureDetector(
                  onTap: _launchUrl,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(RecipeCardTheme.imageRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(RecipeCardTheme.imageRadius),
                      child: CachedNetworkImage(
                        imageUrl: recipe.recipeImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RecipeCardTheme.primaryColor.withOpacity(0.1),
                                RecipeCardTheme.secondaryColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(RecipeCardTheme.imageRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 32,
                              color: RecipeCardTheme.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RecipeCardTheme.primaryColor.withOpacity(0.1),
                                RecipeCardTheme.secondaryColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(RecipeCardTheme.imageRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 32,
                              color: RecipeCardTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 순위 배지
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildRankBadge(),
                ),
                // 출처 배지
                if (recipe.source != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildSourceBadge(),
                  ),
              ],
            ),

            // 레시피 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 레시피명
                  Text(
                    recipe.recipeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RecipeCardTheme.textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 평점
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.averageRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: RecipeCardTheme.textColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${recipe.reviewCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: RecipeCardTheme.subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // 조회수
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 12,
                        color: RecipeCardTheme.subtitleColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.viewCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: RecipeCardTheme.subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeCardSkeleton {
  static Widget skeleton() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(RecipeCardTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(RecipeCardTheme.imageRadius),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 16, width: 80, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(height: 14, width: 60, color: Colors.grey[200]),
          const SizedBox(height: 8),
          Container(height: 12, width: 100, color: Colors.grey[200]),
        ],
      ),
    );
  }
} 