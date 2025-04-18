import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import '../model/recommendation_history.dart';

class HistoryDetailScreen extends StatefulWidget {
  final RecommendationHistory history;
  const HistoryDetailScreen({super.key, required this.history});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final Set<String> likedProductIds = {}; // 찜한 상품 ID 저장용

  NumberFormat get currencyFormatter => NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    final recommendations = widget.history.recommendations;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.5,
        title: const Text(
          '추천 히스토리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('💡 AI가 추천한 상품'),
          if (recommendations.isNotEmpty) _buildSwipeableProducts(recommendations, context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {}); // 임시 리로드 트리거
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: Colors.white24,
              thickness: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableProducts(List<Product> products, BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: products.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final product = products[index];
          final isLiked = likedProductIds.contains(product.productId);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductWebViewScreen(url: product.link),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경 그라데이션
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
                        ),
                      ),
                    ),

                    // 상품 이미지
                    Image.network(
                      product.image.isNotEmpty
                          ? product.image
                          : 'https://via.placeholder.com/800x600',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, color: Colors.white70),
                      ),
                    ),

                    // 몰 이름 띠
                    if (product.mallName.isNotEmpty)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.mallName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // 하단 정보 레이어
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₩ ${currencyFormatter.format(product.price)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isLiked) {
                                        likedProductIds.remove(product.productId);
                                      } else {
                                        likedProductIds.add(product.productId);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.pinkAccent : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            if (product.reason.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '🧠 ${product.reason}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (product.category.isNotEmpty)
                                  Chip(
                                    label: Text(
                                      product.category,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    backgroundColor: Colors.white10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                Chip(
                                  label: const Text(
                                    'AI추천',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.deepPurple.shade100.withOpacity(0.3),
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
            ),
          );
        },
      ),
    );
  }
}
