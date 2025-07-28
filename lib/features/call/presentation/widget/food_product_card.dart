import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/product.dart';
import '../../data/food_api.dart';
import '../../../review/presentation/food_review_overlay_screen.dart';

// 🎨 Modern Food Product Card Theme
class FoodProductCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class FoodProductCard extends StatefulWidget {
  final Product product;
  final int historyId;

  const FoodProductCard({
    super.key,
    required this.product,
    required this.historyId,
  });

  @override
  State<FoodProductCard> createState() => _FoodProductCardState();
}

class _FoodProductCardState extends State<FoodProductCard>
    with SingleTickerProviderStateMixin {
  static final FoodApi _foodApi = FoodApi();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: FoodProductCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    _foodApi.openFood(
      widget.product.productId,
      widget.historyId.toString(),
      widget.product.source ?? '',
    );

    final uri = Uri.parse(widget.product.link);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  void _openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodReviewOverlayScreen(product: widget.product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 가격 문자열 포맷팅
    final priceText = '${widget.product.price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    )}원';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: FoodProductCardTheme.cardBackground,
                borderRadius: BorderRadius.circular(FoodProductCardTheme.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _launchUrl,
                borderRadius: BorderRadius.circular(FoodProductCardTheme.borderRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── 이미지 + mallName 오버레이 ───────────────────────────
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(FoodProductCardTheme.borderRadius),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.product.image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade100,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (c, u, e) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade200,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.black.withOpacity(0.6),
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
                                widget.product.mallName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── 이미지 아래 정보 영역 ───────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상품명 (2줄, 말줄임)
                            Text(
                              widget.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                color: FoodProductCardTheme.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 가격 (한 줄)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FoodProductCardTheme.primaryGradientStart.withOpacity(0.1),
                                    FoodProductCardTheme.primaryGradientEnd.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                priceText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: FoodProductCardTheme.primaryGradientStart,
                                ),
                              ),
                            ),

                            // 후기 (가격 아래)
                            if (widget.product.reviewCount != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FoodProductCardTheme.textSecondary.withOpacity(0.1),
                                            FoodProductCardTheme.textSecondary.withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '후기 ${widget.product.reviewCount}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: FoodProductCardTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 모든 상품에 리뷰보기 버튼 표시
                                  GestureDetector(
                                    onTap: () => _openReviews(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FoodProductCardTheme.secondaryGradientStart,
                                            FoodProductCardTheme.secondaryGradientEnd,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: FoodProductCardTheme.secondaryGradientStart.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.rate_review,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '리뷰보기',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

