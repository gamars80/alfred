import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../review/presentation/review_overlay_screen.dart';
import '../../model/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int historyCreatedAt;      // ← 추가
  final bool? isLiked;
  final VoidCallback? onLikeToggle;
  final String? token;

  const ProductCard({
    super.key,
    required this.product,
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

  void _openWebview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductWebViewScreen(url: product.link),
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

      // 1) 전체 응답을 dynamic 리스트로 받음
      final List<dynamic> data = response.data;

      // 2) 첫 번째 요소(Map)에서 imageUrls 리스트를 추출
      List<String> imageUrls = [];
      if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
        final map = data[0] as Map<String, dynamic>;
        if (map['imageUrls'] is List) {
          imageUrls = (map['imageUrls'] as List).whereType<String>().toList();
        }
      }

      if (imageUrls.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ProductDetailImageViewerScreen(imageUrls: imageUrls),
          ),
        );
      } else {
        debugPrint('[ProductDetailImages] Empty image list');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지를 불러오지 못했습니다.')));
      }
    } catch (e) {
      debugPrint('[ProductDetailImages] Error fetching detail-image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width.toInt();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => _openWebview(context),
              child: CachedNetworkImage(
                imageUrl: _getValidImageUrl(product.image),
                fit: BoxFit.cover,
                memCacheWidth: screenWidth,
                placeholder:
                    (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                errorWidget:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 60),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '₩${_currencyFormatter.format(product.price)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    if (isLiked != null && onLikeToggle != null)
                      IconButton(
                        icon: Icon(
                          isLiked! ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked! ? Colors.pinkAccent : Colors.grey,
                        ),
                        onPressed: onLikeToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                if (product.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                // if (product.reviewCount > 0) ...[
                const SizedBox(height: 8),
                // ⭐ 여기만 수정
                if (product.source == 'ABLY' ||
                    product.source == 'ZIGZAG' ||
                    product.source == 'ATTRANGS' ||
                    product.source == 'HOTPING' ||
                    product.source == 'MUSINSA')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 기존 리뷰보기 버튼
                      TextButton(
                        onPressed: () => _openReviews(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '리뷰보기',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      // 우측 돋보기 아이콘
                      IconButton(
                        icon: const Icon(Icons.search, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _openDetailImage(context),
                      ),
                    ],
                  ),
                // else
                // // 그 외 mallName에는 기존대로 리뷰보기만
                //   Align(
                //     alignment: Alignment.centerLeft,
                //     child: TextButton(
                //       onPressed: () => _openReviews(context),
                //       style: TextButton.styleFrom(
                //         padding: EdgeInsets.zero,
                //         minimumSize: const Size(50, 24),
                //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //       ),
                //       child: const Text(
                //         '리뷰보기',
                //         style: TextStyle(fontSize: 12),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
