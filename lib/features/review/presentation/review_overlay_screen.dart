import 'package:flutter/material.dart';
import '../../call/model/product.dart';
import '../data/review_repository.dart';
import '../model/review.dart';

class ReviewOverlayScreen extends StatefulWidget {
  final Product product;
  final String token;

  const ReviewOverlayScreen({super.key, required this.product, required this.token});

  @override
  State<ReviewOverlayScreen> createState() => _ReviewOverlayScreenState();
}

class _ReviewOverlayScreenState extends State<ReviewOverlayScreen> {
  final repo = ReviewRepository();
  late Future<List<Review>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    reviewsFuture = repo.fetchReviews(widget.product.productId, widget.token);
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
                          '에러 발생: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ));
                  }

                  final reviews = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: reviews.length,
                    itemBuilder: (_, i) {
                      final review = reviews[i];

                      // 옵션을 / 기준으로 두 줄 분리
                      final firstLine = review.selectedOptions.isNotEmpty ? review.selectedOptions.first : '';
                      final secondLine = review.selectedOptions.length > 1 ? review.selectedOptions[1] : '';

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
                                    color: j < review.rating ? Colors.pinkAccent : Colors.grey[300],
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                firstLine,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                secondLine,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.black12, height: 1),
                              const SizedBox(height: 12),
                              Text(
                                review.content,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              if (review.imageUrls.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    review.imageUrls.first,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
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
