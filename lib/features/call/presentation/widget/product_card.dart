import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../review/presentation/review_overlay_screen.dart';
import '../../model/product.dart';

class ProductCard extends StatelessWidget {
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
          url: product.link,
          productId: product.productId,
          historyId: id,
          // historyCreatedAt: historyCreatedAt,
          source: product.source!,
        ),
      ),
    );
  }

  void _openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewOverlayScreen(product: product)),
    );
  }

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      debugPrint('[상품상세이미지] 요청 ID: ${product.source}');

      final response = await DioClient.dio.get(
        '/api/products/${product.productId}?source=${product.source}&detailLink=${product.link}',
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    const Text(
                      '알프레드의 추천 이유',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: GestureDetector(
                    onTap: () => _openWebview(context),
                    child: CachedNetworkImage(
                      imageUrl: _getValidImageUrl(product.image),
                      fit: BoxFit.cover,
                      memCacheWidth: screenWidth,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              product.mallName,
                              style: const TextStyle(
                                fontSize: 10,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF666666),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 10, color: Colors.orange[600]),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.reviewCount}',
                                    style: TextStyle(
                                      fontSize: 10,
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
                      const SizedBox(height: 2),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.reason.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _ReasonWithMore(
                                reason: product.reason,
                                onMore: () => _showFullReason(context),
                              ),
                            ],
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 10,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₩${_currencyFormatter.format(product.price)}',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 2,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (product.source == 'ZIGZAG' ||
                          product.source == 'ATTRANGS' ||
                          product.source == 'HOTPING' ||  product.source == '29CM' ||
                          product.source == 'MUSINSA' || product.source == 'XEXYMIX' || product.source == 'QUEENIT')
                        Container(
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              if (product.source != '29CM' && product.source != 'HOTPING' && product.source != 'XEXYMIX')
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _openDetailImage(context),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFF8F8F8),
                                      foregroundColor: const Color(0xFF424242),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 20),
                                      maximumSize: const Size(double.infinity, 20),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_outlined, size: 10, color: Colors.grey[700]),
                                        const SizedBox(width: 2),
                                        Text(
                                          '상세',
                                          style: TextStyle(
                                            fontSize: 9,
                                            height: 1.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (product.source != '29CM' && product.source != 'HOTPING' && product.source != 'XEXYMIX')
                                const SizedBox(width: 4),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => _openReviews(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8F8F8),
                                    foregroundColor: const Color(0xFF424242),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 20),
                                    maximumSize: const Size(double.infinity, 20),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rate_review_outlined, size: 10, color: Colors.grey[700]),
                                      const SizedBox(width: 2),
                                      Text(
                                        '리뷰',
                                        style: TextStyle(
                                          fontSize: 9,
                                          height: 1.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
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
          if (token != null)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLikeToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLiked == true ? Icons.favorite : Icons.favorite_border,
                      color: isLiked == true ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
        fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.reason,
              style: const TextStyle(
                fontSize: 10,
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
              child: Padding(
                padding: const EdgeInsets.only(left: 4, top: 1),
                child: Text(
                  '더보기',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

