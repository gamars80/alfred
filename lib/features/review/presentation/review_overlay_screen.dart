import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../call/model/product.dart';
import '../data/review_repository.dart';
import '../model/review.dart';

class ReviewOverlayScreen extends StatefulWidget {
  final Product product;

  const ReviewOverlayScreen({super.key, required this.product});

  @override
  State<ReviewOverlayScreen> createState() => _ReviewOverlayScreenState();
}

class _ReviewOverlayScreenState extends State<ReviewOverlayScreen> {
  final repo = ReviewRepository();
  late Future<List<Review>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    reviewsFuture = repo.fetchReviews(
      productId: widget.product.productId,
      mallName: _normalizeMallName(widget.product.mallName),
      productLink: widget.product.link,
    );
  }

  String _normalizeMallName(String mallName) {
    switch (mallName) {
      case '지그재그':
        return 'ZIGZAG';
      case '핫핑':
        return 'HOTPING';
      case '에이인':
        return 'AIN';
      default:
        return mallName.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.05),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: const Text('📝 리뷰', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Review>>(
                future: reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '에러 발생: \${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final reviews = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, i) {
                      final review = reviews[i];

                      // 옵션을 / 기준으로 두 줄 분리
                      final firstLine = review.selectedOptions.isNotEmpty
                          ? review.selectedOptions.first
                          : '';
                      final secondLine = review.selectedOptions.length > 1
                          ? review.selectedOptions[1]
                          : '';

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                      (j) => Icon(
                                    Icons.favorite,
                                    color: j < review.rating
                                        ? Colors.pinkAccent
                                        : Colors.grey[300],
                                    size: 16,
                                  ),
                                ),
                              ),

                              if (firstLine.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  firstLine,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                              ],

                              if (secondLine.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  secondLine,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                              ],

                              const SizedBox(height: 12),
                              const Divider(color: Colors.black12, height: 1),
                              const SizedBox(height: 12),

                              Text(
                                review.content,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.black87),
                              ),

                              if (review.imageUrls.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 200,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: review.imageUrls.length,
                                    separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          review.imageUrls[index],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.contain,
                                          placeholder: (_, __) => const Center(
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )),
                                          errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
