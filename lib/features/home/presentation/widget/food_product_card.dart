import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/popular_food_product.dart';

class FoodProductCardTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 배경 색상
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double imageRadius = 16.0;
}

class FoodProductCard extends StatelessWidget {
  final PopularFoodProduct? product;
  final int? rank;
  final VoidCallback? onTap;
  final bool isSkeleton;

  const FoodProductCard({
    super.key,
    required this.product,
    this.rank,
    this.onTap,
  }) : isSkeleton = false;

  const FoodProductCard.skeleton({super.key})
      : product = null,
        rank = null,
        onTap = null,
        isSkeleton = true;

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(price)}원';
  }

  void _launchProductLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('외부 브라우저를 열 수 없습니다.')),
      );
    }
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor;
    
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // 골드
      textColor = const Color(0xFF8B4513);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // 실버
      textColor = const Color(0xFF2F4F4F);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // 브론즈
      textColor = Colors.white;
    } else {
      badgeColor = FoodProductCardTheme.primaryGradientStart;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: rank <= 3 
            ? null 
            : LinearGradient(
                colors: [
                  FoodProductCardTheme.primaryGradientStart,
                  FoodProductCardTheme.primaryGradientEnd,
                ],
              ),
        color: rank <= 3 ? badgeColor : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank <= 3) ...[
            Icon(
              rank == 1 ? Icons.emoji_events_rounded : 
              rank == 2 ? Icons.workspace_premium_rounded : 
              Icons.military_tech_rounded,
              size: 12,
              color: textColor,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            'TOP $rank',
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FoodProductCardTheme.secondaryGradientStart,
            FoodProductCardTheme.secondaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        source,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSkeleton) {
      return Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(FoodProductCardTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(FoodProductCardTheme.imageRadius),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 16, width: 80, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 14, width: 60, color: Colors.grey[200]),
            const SizedBox(height: 8),
            Container(height: 12, width: 100, color: Colors.grey[200]),
            const SizedBox(height: 8),
            Container(height: 18, width: 50, color: Colors.grey[200]),
          ],
        ),
      );
    }

    final p = product!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: FoodProductCardTheme.backgroundColor,
          borderRadius: BorderRadius.circular(FoodProductCardTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _launchProductLink(context, p.productLink),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FoodProductCardTheme.imageRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FoodProductCardTheme.imageRadius),
                      child: CachedNetworkImage(
                        imageUrl: p.productImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FoodProductCardTheme.primaryGradientStart.withOpacity(0.1),
                                FoodProductCardTheme.primaryGradientEnd.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(FoodProductCardTheme.imageRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 32,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FoodProductCardTheme.primaryGradientStart.withOpacity(0.1),
                                FoodProductCardTheme.primaryGradientEnd.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(FoodProductCardTheme.imageRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 32,
                              color: Color(0xFF667eea),
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
                  child: _buildRankBadge(rank!),
                ),
                // 출처 배지
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildSourceBadge(p.source),
                ),
              ],
            ),

            // 상품 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품명
                  Text(
                    p.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 가격
                  Text(
                    _formatPrice(p.productPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // 리뷰 수
                  Row(
                    children: [
                      Icon(
                        Icons.rate_review_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${p.reviewCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // 쇼핑몰
                  Text(
                    p.mallName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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