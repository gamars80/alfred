import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../model/liked_product.dart';

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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  _getValidImageUrl(product.productImage),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, color: Colors.white70),
                  ),
                ),
              ),
            ),

            // 내용 부분을 Expanded로 감싸기
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ 1. 상품명 - Flexible로 감싸고 maxLines, overflow 꼭 설정
                    Flexible(
                      child: Text(
                        product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ✅ 2. 가격
                    Text(
                      '₩${formatter.format(product.productPrice)}',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// ✅ 3. 쇼핑몰명
                    Text(
                      product.mallName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white60,
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
