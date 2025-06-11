import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/foods_history.dart';

class FoodsHistoryCard extends StatelessWidget {
  final FoodsHistory history;
  final VoidCallback onTap;

  const FoodsHistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  String? _extractTag() {
    if (history.ingredients?.isNotEmpty ?? false) {
      final ingredients = history.ingredients!;
      if (ingredients.startsWith('[') && ingredients.endsWith(']')) {
        // [] 제거하고 반환
        final content = ingredients.substring(1, ingredients.length - 1).trim();
        // content가 비어있거나 "[]"인 경우 suggested 값을 사용
        if (content.isEmpty || content == "[]") {
          return history.suggested;
        }
        return content.isNotEmpty ? content : null;
      }
      return ingredients;
    } else if (history.suggested?.isNotEmpty ?? false) {
      return history.suggested;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tag = _extractTag();
    final hasRecommendations = history.recommendations.isNotEmpty;
    final hasRecipes = history.recipes.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 쿼리 텍스트
                Text(
                  history.query ?? '음식 추천',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                
                // 태그
                if (tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 추천 요약 정보
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (hasRecommendations)
                      _buildInfoChip(
                        Icons.shopping_cart_outlined,
                        '${history.recommendations.length}개의 상품',
                        Colors.blue,
                      ),
                    if (hasRecipes)
                      _buildInfoChip(
                        Icons.restaurant_menu,
                        '${history.recipes.length}개의 레시피',
                        Colors.green,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 평점과 상태
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          (history.hasRating && history.myRating != null && index < history.myRating!) 
                              ? Icons.star 
                              : Icons.star_border,
                          size: 18,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: history.status == 'WAITING' ? Colors.orange.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        history.status == 'WAITING' ? '처리대기중' : '완료',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: history.status == 'WAITING' ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 날짜와 화살표
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(history.createdAt),
                      ),
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
} 