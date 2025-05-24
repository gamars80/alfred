import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/product_detail_image_viewer_screen.dart';
import '../../../call/model/product.dart';
import '../../../review/presentation/review_overlay_screen.dart';


class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  void _openLink(BuildContext context) async {
    final url = Uri.parse(product.link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 220),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openLink(context),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1, // 정사각형 이미지
                      child: CachedNetworkImage(
                        imageUrl: product.image.startsWith('http')
                            ? product.image
                            : 'https:${product.image}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                      ),
                    ),
                    // ✅ mallName 배지
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.mallName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    // const Spacer(),
                    const SizedBox(height: 6),
                    Text(
                      '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openReviews(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.reviews, size: 12, color: Colors.black54),
                                SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    '리뷰',
                                    style: TextStyle(fontSize: 9, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openDetailImage(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Icon(Icons.image_search, size: 12, color: Colors.black54),
                                SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    '상세',
                                    style: TextStyle(fontSize: 9, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}
