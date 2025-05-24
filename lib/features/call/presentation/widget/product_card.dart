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
        builder: (_) => ProductWebViewScreen(
          url: product.link,
          productId: product.productId,
          historyCreatedAt: historyCreatedAt,
          source: product.source!, // null 아님이 보장된다면 ! 사용
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.0,  // 강제로 정사각형으로 설정
            child: ClipRRect(  // 이미지를 정사각형으로 자르기
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
          Expanded(  // 남은 공간을 모두 사용
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(  // 상단 영역 (쇼핑몰명, 리뷰)
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
                            fontSize: 8,
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
                              Icon(Icons.star_rounded, size: 8, color: Colors.orange[600]),
                              const SizedBox(width: 2),
                              Text(
                                '${product.reviewCount}',
                                style: TextStyle(
                                  fontSize: 8,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              product.reason,
                              style: const TextStyle(
                                fontSize: 8,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₩${_currencyFormatter.format(product.price)}',
                          style: const TextStyle(
                            fontSize: 12,
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
                  if (product.source == 'ABLY' ||
                      product.source == 'ZIGZAG' ||
                      product.source == 'ATTRANGS' ||
                      product.source == 'HOTPING' ||
                      product.source == 'MUSINSA')
                    Container(  // 하단 영역 (버튼)
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
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
    );
  }
}

