import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../model/popular_product.dart';

class PopularProductCardTheme {
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

class PopularProductCard extends StatefulWidget {
  final PopularProduct product;
  final int rank;
  final VoidCallback? onTap;

  const PopularProductCard({
    Key? key,
    required this.product,
    required this.rank,
    this.onTap,
  }) : super(key: key);

  @override
  State<PopularProductCard> createState() => _PopularProductCardState();
}

class _PopularProductCardState extends State<PopularProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}원';
  }

  Future<void> _handleImageClick(BuildContext context) async {
    final encodedSource = Uri.encodeComponent(widget.product.source);
    final apiPath =
        '/api/products/${widget.product.productId}/${widget.product.historyId}/$encodedSource/open/${widget.product.userId}';

    try {
      final response = await DioClient.dio.post(apiPath);

      if (response.statusCode == 200) {
        final uri = Uri.parse(widget.product.productLink);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('브라우저를 열 수 없습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API 호출 실패: 상태 코드 ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('[PopularProductCard] API 호출 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API 호출 중 오류가 발생했습니다.')),
      );
    }
  }

  Widget _buildRankBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: PopularProductCardTheme.rankGradient,
          borderRadius: BorderRadius.circular(PopularProductCardTheme.badgeRadius),
          boxShadow: [
            BoxShadow(
              color: PopularProductCardTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'TOP ${widget.rank}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: PopularProductCardTheme.sourceGradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          widget.product.source,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isHovered = true);
              _scaleController.forward();
            },
            onTapUp: (_) {
              setState(() => _isHovered = false);
              _scaleController.reverse();
            },
            onTapCancel: () {
              setState(() => _isHovered = false);
              _scaleController.reverse();
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: PopularProductCardTheme.elegantBackground,
                borderRadius: BorderRadius.circular(PopularProductCardTheme.cardRadius),
                boxShadow: PopularProductCardTheme.cardShadow,
                border: Border.all(
                  color: PopularProductCardTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _handleImageClick(context),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(PopularProductCardTheme.cardRadius),
                          ),
                          child: ExtendedImage.network(
                            widget.product.productImage,
                            width: 180,
                            height: 120,
                            fit: BoxFit.cover,
                            cache: true,
                            loadStateChanged: (state) {
                              if (state.extendedImageLoadState == LoadState.failed) {
                                return Container(
                                  width: 180,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[200]!,
                                        Colors.grey[300]!,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      _buildRankBadge(),
                      _buildSourceBadge(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.productName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: PopularProductCardTheme.textColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PopularProductCardTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.product.mallName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: PopularProductCardTheme.primaryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatPrice(widget.product.productPrice),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: PopularProductCardTheme.priceColor,
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
          ),
        );
      },
    );
  }
}
