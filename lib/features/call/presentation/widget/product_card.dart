import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../review/presentation/review_overlay_screen.dart';
import '../../model/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final int id;
  final int historyCreatedAt;
  final bool? isLiked;
  final VoidCallback? onLikeToggle;
  final String? token;

  const ProductCard({
    super.key,
    required this.product,
    required this.id,
    required this.historyCreatedAt,
    this.isLiked,
    this.onLikeToggle,
    this.token,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductWebViewScreen(
          url: widget.product.link,
          productId: widget.product.productId,
          historyId: widget.id,
          source: widget.product.source!,
        ),
      ),
    );
  }

  void _openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewOverlayScreen(product: widget.product)),
    );
  }

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      debugPrint('[상품상세이미지] 요청 ID: ${widget.product.source}');

      final response = await DioClient.dio.get(
        '/api/products/${widget.product.productId}?source=${widget.product.source}&detailLink=${widget.product.link}',
      );

      final List<dynamic> data = response.data;
      List<String> imageUrls = [];
      if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
        final map = data[0] as Map<String, dynamic>;
        if (map['imageUrls'] is List) {
          imageUrls = (map['imageUrls'] as List).whereType<String>().toList();
        }
      }

      if (imageUrls.isNotEmpty && context.mounted) {
        debugPrint("imageUrls:::::::::::::::::::::::::$imageUrls");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailImageViewerScreen(imageUrls: imageUrls),
          ),
        );
      } else {
        debugPrint('[ProductDetailImages] Empty image list');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지를 불러오지 못했습니다.')),
          );
        }
      }
    } catch (e) {
      debugPrint('[ProductDetailImages] Error fetching detail-image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _showFullReason(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '알프레드의 추천 이유',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.product.reason,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF212121),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
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
                                        color: Color(0xFF666666),
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
                              const SizedBox(height: 8),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.product.reason.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      _ReasonWithMore(
                                        reason: widget.product.reason,
                                        onMore: () => _showFullReason(context),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
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
                                    const SizedBox(height: 6),
                                    Text(
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
                                  ],
                                ),
                              ),
                              if (widget.product.source == 'ZIGZAG' ||
                                  widget.product.source == 'ATTRANGS' ||
                                  widget.product.source == 'HOTPING' ||  widget.product.source == '29CM' ||
                                  widget.product.source == 'MUSINSA' || widget.product.source == 'XEXYMIX' || widget.product.source == 'QUEENIT')
                                Container(
                                  height: 32,
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      if (widget.product.source != '29CM' && widget.product.source != 'HOTPING' && widget.product.source != 'XEXYMIX')
                                        Expanded(
                                          child: _buildActionButton(
                                            onPressed: () => _openDetailImage(context),
                                            icon: Icons.image_outlined,
                                            label: '상세',
                                            color: const Color(0xFF1976D2),
                                          ),
                                        ),
                                      if (widget.product.source != '29CM' && widget.product.source != 'HOTPING' && widget.product.source != 'XEXYMIX')
                                        const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildActionButton(
                                          onPressed: () => _openReviews(context),
                                          icon: Icons.rate_review_outlined,
                                          label: '리뷰',
                                          color: const Color(0xFF4CAF50),
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
                  if (widget.token != null)
                    Positioned(
                      top: 12,
                      right: 12,
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

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonWithMore extends StatefulWidget {
  final String reason;
  final VoidCallback onMore;
  const _ReasonWithMore({required this.reason, required this.onMore});

  @override
  State<_ReasonWithMore> createState() => _ReasonWithMoreState();
}

class _ReasonWithMoreState extends State<_ReasonWithMore> {
  bool _isOverflow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final span = TextSpan(
      text: widget.reason,
      style: const TextStyle(
        fontSize: 11,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1976D2),
      ),
    );
    final tp = TextPainter(
      text: span,
      maxLines: 2,
      textDirection: Directionality.of(context),
    );
    tp.layout(maxWidth: context.size?.width ?? 200);
    setState(() {
      _isOverflow = tp.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.reason,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isOverflow)
            GestureDetector(
              onTap: widget.onMore,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

