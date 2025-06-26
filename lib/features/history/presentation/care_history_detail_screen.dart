import 'package:flutter/material.dart';
import 'package:alfred_clean/features/call/presentation/widget/care_product_card.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:alfred_clean/features/history/model/care_history.dart';
import 'package:alfred_clean/features/history/presentation/widget/care_history_card.dart';
import 'package:alfred_clean/features/like/presentation/liked_product_screen.dart';
import 'package:alfred_clean/features/like/data/services/food_like_service.dart';

class CareHistoryDetailScreen extends StatefulWidget {
  final CareHistory history;

  const CareHistoryDetailScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<CareHistoryDetailScreen> createState() => _CareHistoryDetailScreenState();
}

class _CareHistoryDetailScreenState extends State<CareHistoryDetailScreen> {
  late CareHistory _history;
  bool _isReasonExpanded = false; // 추천이유 섹션 접기/펼치기 상태

  @override
  void initState() {
    super.initState();
    _history = widget.history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '뷰티케어 히스토리',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedProductScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 히스토리 카드
          CareHistoryCard(
            history: _history,
            onTap: () {}, // 상세 화면에서는 탭 비활성화
          ),
          const SizedBox(height: 16),
          
          // 추천이유 섹션 (reason이 있을 때만 표시)
          if (_history.reason != null && _history.reason!.isNotEmpty) ...[
            _buildReasonSection(),
            const SizedBox(height: 16),
          ],
          
          // 상품 목록
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 290,
              ),
              itemCount: _history.recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = _history.recommendations[index];
                final product = recommendation.toProduct();
                
                return CareProductCard(
                  product: product,
                  id: _history.id,
                  historyCreatedAt: _history.createdAt,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF7B1FA2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '알프레드의 추천이유',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            initiallyExpanded: _isReasonExpanded,
            onExpansionChanged: (value) {
              setState(() {
                _isReasonExpanded = value;
              });
            },
            tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE1BEE7),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _history.reason!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                          height: 1.5,
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
    );
  }
} 