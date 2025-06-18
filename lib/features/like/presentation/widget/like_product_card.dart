import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../model/liked_product.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../review/presentation/review_overlay_screen.dart';

class LikedProductCard extends StatelessWidget {
  final LikedProduct product;
  final VoidCallback onTap;
  final VoidCallback onUnLike;

  const LikedProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onUnLike,
  });

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      debugPrint('[상품상세이미지] 요청 ID: ${product.source}');

      final response = await DioClient.dio.get(
        '/api/products/${product.productId}?source=${product.source}&detailLink=${product.productLink}',
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

  void _openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewOverlayScreen(product: product.toProduct())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  _getValidImageUrl(product.productImage),
                  fit: BoxFit.fitHeight,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),

            // 찜취소 버튼
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onUnLike,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),

            // 내용
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₩${formatter.format(product.productPrice)}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      product.mallName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (product.source == 'ABLY' ||
                        product.source == 'ZIGZAG' ||
                        product.source == 'ATTRANGS' ||
                        product.source == 'HOTPING' ||
                        product.source == '29CM' ||
                        product.source == 'MUSINSA' ||
                        product.source == 'XEXYMIX' ||
                        product.source == 'QUEENIT')
                      Container(
                        height: 20,
                        margin: const EdgeInsets.only(top: 4),
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
      ),
    );
  }

  String _getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }
    if (url.startsWith('//')) return 'https:$url';
    if (!url.startsWith('http')) return 'https://via.placeholder.com/300x300.png?text=Invalid+URL';
    return url;
  }
}
