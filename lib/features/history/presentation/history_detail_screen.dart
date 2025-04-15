import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import '../model/recommendation_history.dart';

class HistoryDetailScreen extends StatelessWidget {
  final RecommendationHistory history;
  final currencyFormatter = NumberFormat('#,###', 'ko_KR');

  HistoryDetailScreen({super.key, required this.history});

  Widget _buildProductCard(Product product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductWebViewScreen(url: product.link),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // 텍스트 영역 (배경 추가)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.mallName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.mallName,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // 상품명 (강조 스타일)
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 가격
                  Text(
                    '₩ ${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  // 추천 사유
                  if (product.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        product.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = history.recommendations;
    return Scaffold(
      appBar: AppBar(title: const Text('추천 상품')),
      body: recommendations.isEmpty
          ? const Center(child: Text('추천 상품이 없습니다.'))
          : ListView.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final product = recommendations[index];
          return _buildProductCard(product, context);
        },
      ),
    );
  }
}
