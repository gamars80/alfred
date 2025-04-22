import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import '../../../service/token_manager.dart';
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
  final Set<String> likedProductIds = {}; // 찜한 상품 ID 저장용
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {});
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.refresh),
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
                // 🔝 이미지 (크게)
                SizedBox(
                  height: screenHeight * 0.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductWebViewScreen(url: product.link),
                        ),
                      ),
                      child: Image.network(
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
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 🧾 정보 카드
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₩ ${currencyFormatter.format(product.price)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isLiked ? Colors.pinkAccent : Colors.grey,
                                ),
                                onPressed: () async {
                                  if (token == null) return;
                                  try {
                                    if (isLiked) {
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
                                },
                              ),
                            ],
                          ),
                          if (product.reason.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '🧠 ${product.reason}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (product.category.isNotEmpty)
                                Chip(
                                  label: Text(
                                    product.category,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                ),
                              Chip(
                                label: const Text(
                                  'AI추천',
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.deepPurple.shade100.withOpacity(0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              ),
                            ],
                          ),
                        ],
                      ),
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


}
