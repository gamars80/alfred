import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/utils/toast_util.dart';

import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../review/presentation/review_overlay_screen.dart';
import '../../data/care_api.dart';
import '../../model/product.dart';

class CareProductCard extends StatefulWidget {
  final Product product;
  final int id;
  final int historyCreatedAt;
  final bool? isLiked;
  final VoidCallback? onLikeToggle;
  final String? token;

  const CareProductCard({
    super.key,
    required this.product,
    required this.id,
    required this.historyCreatedAt,
    this.isLiked,
    this.onLikeToggle,
    this.token,
  });

  @override
  State<CareProductCard> createState() => _CareProductCardState();
}

class _CareProductCardState extends State<CareProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  static final _currencyFormatter = NumberFormat('#,###', 'ko_KR');

  String _getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/200x200.png?text=No+Image';
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (!url.startsWith('http')) {
      return 'https://via.placeholder.com/200x200.png?text=Invalid+URL';
    }
    return url;
  }

  Future<void> _openWebview(BuildContext context) async {
    _animationController.reverse().then((_) async {
      // 브라우저를 열기 전에 API 호출
      final careApi = CareApi();
      careApi.openCare(
        widget.product.productId,
        widget.id.toString(),
        widget.product.source ?? '',
      );

      final uri = Uri.parse(widget.product.link);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('브라우저를 열 수 없습니다.')),
          );
        }
      }
    });
  }

  void _openReviews(BuildContext context) {
    _animationController.reverse().then((_) {
      // Product의 category를 'care'로 설정하여 뷰티케어 리뷰 API 호출
      final productForReview = Product(
        recommendationId: widget.product.recommendationId,
        name: widget.product.name,
        productId: widget.product.productId,
        price: widget.product.price,
        image: widget.product.image,
        link: widget.product.link,
        reason: widget.product.reason,
        mallName: widget.product.mallName,
        category: 'care', // 뷰티케어 카테고리로 설정
        liked: widget.product.liked,
        reviewCount: widget.product.reviewCount,
        source: widget.product.source,
        productDescription: widget.product.productDescription,
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewOverlayScreen(product: productForReview),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width.toInt();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: GestureDetector(
                            onTap: () => _openWebview(context),
                            child: CachedNetworkImage(
                              imageUrl: _getValidImageUrl(widget.product.image),
                              fit: BoxFit.cover,
                              memCacheWidth: screenWidth,
                              placeholder: (_, __) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                                  ),
                                ),
                                child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.product.reason.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1976D2).withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.product.reason,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            height: 1.3,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1976D2),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (widget.product.productDescription != null && widget.product.productDescription!.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF7B1FA2).withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.product.productDescription!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            height: 1.3,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF7B1FA2),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      widget.product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF212121),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '₩${_currencyFormatter.format(widget.product.price)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.2,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (widget.product.reviewCount > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange.withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star_rounded, size: 12, color: Colors.orange[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${widget.product.reviewCount}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    height: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      height: 36,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            if (widget.product.reviewCount > 0) {
                                              _openReviews(context);
                                            } else {
                                              ToastUtil.showOverlay(
                                                context,
                                                '리뷰가 존재하지 않습니다',
                                              );
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFF7B1FA2).withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.rate_review_outlined,
                                                  size: 16,
                                                  color: const Color(0xFF7B1FA2),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '리뷰보기',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF7B1FA2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // mallName을 이미지 우측 상단에 배치
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
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
                          fontSize: 11,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (widget.token != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onLikeToggle,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isLiked == true ? Icons.favorite : Icons.favorite_border,
                              color: widget.isLiked == true ? Colors.red : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 