import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/care_product.dart';
import '../../../review/presentation/review_overlay_screen.dart';
import '../../../call/model/product.dart';

class CareProductCard extends StatelessWidget {
  final CareProduct product;

  const CareProductCard({super.key, required this.product});

  void _openLink(BuildContext context) async {
    final url = Uri.parse(product.productLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  void _openReviews(BuildContext context) {
    // CareProduct를 Product로 변환하여 리뷰 화면에 전달
    final productForReview = Product(
      recommendationId: product.historyId,
      name: product.productName,
      productId: product.productId,
      price: product.productPrice,
      link: product.productLink,
      image: product.productImage,
      reason: '',
      mallName: product.mallName,
      category: 'care', // 뷰티케어 카테고리로 설정
      liked: product.liked,
      reviewCount: product.reviewCount,
      source: product.source,
      productDescription: product.productDescription,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewOverlayScreen(product: productForReview)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: product.productImage.startsWith('http')
                          ? product.productImage
                          : 'https:${product.productImage}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
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
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.productDescription != null && product.productDescription!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '설명: ${product.productDescription!}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 3),
                    Text(
                      '설명 없음',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${product.productPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  if (product.reviewCount > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 11,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '리뷰 ${product.reviewCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openReviews(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '리뷰보기',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.deepPurple[700],
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }
} 