import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../service/token_manager.dart';
import '../../review/presentation/review_overlay_screen.dart';
import '../data/history_repository.dart';
import '../model/recommendation_history.dart';

class HistoryDetailScreen extends StatefulWidget {
  final RecommendationHistory history;
  const HistoryDetailScreen({super.key, required this.history});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final repo = HistoryRepository();
  final Set<String> likedProductIds = {};
  String? token;

  @override
  void initState() {
    super.initState();

    for (final p in widget.history.recommendations) {
      if (p.liked) likedProductIds.add(p.productId);
    }

    _loadToken();
  }

  Future<void> _loadToken() async {
    final t = await TokenManager.getToken();
    setState(() {
      token = t;
    });
  }

  NumberFormat get currencyFormatter => NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    final recommendations = widget.history.recommendations;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.history);
        return false;
      },
      child: Scaffold(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, widget.history),
          ),
        ),
        body: ListView(
          children: [
            _buildSectionTitle('💡 AI가 추천한 상품'),
            if (recommendations.isNotEmpty)
              _buildSwipeableProducts(recommendations, context),
          ],
        ),
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
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.7,
      child: PageView.builder(
        itemCount: products.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final product = products[index];
          final isLiked = likedProductIds.contains(product.productId);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.35,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductWebViewScreen(url: product.link),
                            ),
                          ),
                          child: Image.network(
                            _getValidImageUrl(product.image),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade800,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (product.category.isNotEmpty)
                              _buildTag(product.category, Colors.black54),
                            _buildTag('AI추천', Colors.deepPurple.withOpacity(0.6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₩ ${currencyFormatter.format(product.price)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? Colors.pinkAccent : Colors.grey,
                              ),
                              onPressed: () => _toggleLike(product, index),
                            ),
                          ],
                        ),
                        if (product.reason.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '🧠 ${product.reason}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        if (product.reviewCount > 0)
                          GestureDetector(
                            onTap: () {
                              if (token == null) return;
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => ReviewOverlayScreen(product: product, token: token!),
                                ),
                              );
                            },
                            child: Text(
                              '📝 리뷰 보기',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _toggleLike(Product product, int index) async {
    if (token == null) return;
    try {
      if (likedProductIds.contains(product.productId)) {
        await repo.deleteLike(
          historyCreatedAt: widget.history.createdAt,
          recommendationId: product.recommendationId,
          productId: product.productId,
          mallName: product.mallName,
          token: token!,
        );
        final updated = product.copyWith(liked: false);
        setState(() {
          likedProductIds.remove(product.productId);
          widget.history.recommendations[index] = updated;
        });
      } else {
        await repo.postLike(
          historyCreatedAt: widget.history.createdAt,
          recommendationId: product.recommendationId,
          productId: product.productId,
          mallName: product.mallName,
          token: token!,
        );
        final updated = product.copyWith(liked: true);
        setState(() {
          likedProductIds.add(product.productId);
          widget.history.recommendations[index] = updated;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 실패: $e')),
      );
    }
  }

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
}