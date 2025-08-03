import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/popular_care_like.dart';

class CareLikeProductCardTheme {
  // 뷰티다운 우아한 색상 팔레트
  static const Color primaryColor = Color(0xFFE91E63); // 핑크
  static const Color secondaryColor = Color(0xFFF06292); // 연한 핑크
  static const Color accentColor = Color(0xFFFFC0CB); // 라이트 핑크
  static const Color elegantBackground = Color(0xFFFFF5F7); // 우아한 크림색
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);
  static const Color priceColor = Color(0xFFE91E63);
  
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
      color: Color(0x0AE91E63),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  // 랭킹 배지 그라데이션
  static const LinearGradient rankGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 소스 배지 그라데이션
  static const LinearGradient sourceGradient = LinearGradient(
    colors: [Color(0xFFF06292), Color(0xFFFFC0CB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class CareLikeProductCard extends StatelessWidget {
  final PopularCareLike? product;
  final int? rank;
  final VoidCallback? onTap;
  final bool isSkeleton;

  const CareLikeProductCard({
    super.key,
    required this.product,
    this.rank,
    this.onTap,
  }) : isSkeleton = false;

  const CareLikeProductCard.skeleton({super.key})
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

  @override
  Widget build(BuildContext context) {
    if (isSkeleton) {
      return Container(
        width: 160,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 16, width: 80, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Container(height: 14, width: 60, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Container(height: 12, width: 100, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Container(height: 18, width: 50, color: Colors.grey.shade200),
          ],
        ),
      );
    }

    final p = product!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 220,
        decoration: BoxDecoration(
          color: CareLikeProductCardTheme.elegantBackground,
          borderRadius: BorderRadius.circular(CareLikeProductCardTheme.cardRadius),
          border: Border.all(color: CareLikeProductCardTheme.primaryColor.withOpacity(0.3)),
          boxShadow: CareLikeProductCardTheme.cardShadow,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  onTap: () => _launchProductLink(context, p.productLink),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      p.productImage,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                if (rank != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: CareLikeProductCardTheme.rankGradient,
                        borderRadius: BorderRadius.circular(CareLikeProductCardTheme.badgeRadius),
                        boxShadow: [
                          BoxShadow(
                            color: CareLikeProductCardTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'TOP $rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: CareLikeProductCardTheme.sourceGradient,
                      borderRadius: BorderRadius.circular(CareLikeProductCardTheme.badgeRadius),
                      boxShadow: [
                        BoxShadow(
                          color: CareLikeProductCardTheme.secondaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      p.mallName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: CareLikeProductCardTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatPrice(p.productPrice),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: CareLikeProductCardTheme.priceColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.favorite, size: 13, color: CareLikeProductCardTheme.primaryColor),
                      const SizedBox(width: 2),
                      Text(
                        p.cnt.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: CareLikeProductCardTheme.subtitleColor,
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