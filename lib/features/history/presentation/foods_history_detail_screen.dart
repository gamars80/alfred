import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/foods_history.dart';
import '../data/history_repository.dart';

class FoodsHistoryDetailScreen extends StatefulWidget {
  final FoodsHistory history;

  const FoodsHistoryDetailScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<FoodsHistoryDetailScreen> createState() => _FoodsHistoryDetailScreenState();
}

class _FoodsHistoryDetailScreenState extends State<FoodsHistoryDetailScreen> {
  late FoodsHistory _history;
  final HistoryRepository _repository = HistoryRepository();
  bool _isRating = false;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
  }

  String? _extractTag() {
    if (_history.ingredients?.isNotEmpty ?? false) {
      final ingredients = _history.ingredients!;
      if (ingredients.startsWith('[') && ingredients.endsWith(']')) {
        // [] 제거하고 반환
        final content = ingredients.substring(1, ingredients.length - 1).trim();
        // content가 비어있거나 "[]"인 경우 suggested 값을 사용
        if (content.isEmpty || content == "[]") {
          return _history.suggested;
        }
        return content.isNotEmpty ? content : null;
      }
      return ingredients;
    } else if (_history.suggested?.isNotEmpty ?? false) {
      return _history.suggested;
    }
    return null;
  }

  Future<void> _submitRating(int rating) async {
    if (_isRating) return;
    setState(() => _isRating = true);

    try {
      await _repository.postRating(
        historyId: _history.id,
        rating: rating,
      );
      setState(() {
        _history = _history.copyWith(
          hasRating: true,
          myRating: rating,
        );
      });
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('평점 등록에 실패했습니다.')),
        );
      }
    } finally {
      setState(() => _isRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRecommendations = _history.recommendations.isNotEmpty;
    final hasRecipes = _history.recipes.isNotEmpty;
    final tag = _extractTag();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('상세 히스토리',
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 쿼리 및 태그 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _history.query ?? '음식 추천',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (tag != null) Container(
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(_history.createdAt),
                        ),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _history.status == 'WAITING' ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _history.status == 'WAITING' ? '처리대기중' : '완료',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _history.status == 'WAITING' ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 평점 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추천 평가하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: _isRating ? null : () => _submitRating(index + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            (_history.hasRating && _history.myRating != null && index < _history.myRating!)
                                ? Icons.star
                                : Icons.star_border,
                            size: 32,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 추천 상품 섹션
            if (hasRecommendations) Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '추천 상품 ${_history.recommendations.length}개',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _history.recommendations.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final product = _history.recommendations[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: product.productImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.productImage!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_not_supported),
                              ),
                        title: Text(
                          product.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${NumberFormat('#,###').format(product.productPrice)}원',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              product.mallName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 상품 상세 페이지로 이동
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 추천 레시피 섹션
            if (hasRecipes) Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '추천 레시피 ${_history.recipes.length}개',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _history.recipes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final recipe = _history.recipes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.recipeImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          recipe.recipeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.shade400),
                            const SizedBox(width: 4),
                            Text(
                              recipe.averageRating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              NumberFormat('#,###').format(recipe.viewCount),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 레시피 상세 페이지로 이동
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 