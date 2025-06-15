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

class _ProductGridItem extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final int price;
  final String mallName;
  final int? reviewCount;
  final double? rating;
  final String? description;
  final VoidCallback? onTap;

  const _ProductGridItem({
    super.key,
    this.imageUrl,
    required this.name,
    required this.price,
    required this.mallName,
    this.reviewCount,
    this.rating,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 이미지 + 몰 이름 (Stack으로 겹침)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade100),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mallName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2) 상품명 + 설명 + 가격 + 리뷰 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.3,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(price)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (reviewCount != null && reviewCount! > 0)
                      Text(
                        '후기 $reviewCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
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
}

class _RecipeGridItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final int viewCount;
  final VoidCallback? onTap;

  const _RecipeGridItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.viewCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text(
                          NumberFormat('#,###').format(viewCount),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
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
    );
  }
}

class _FoodsHistoryDetailScreenState extends State<FoodsHistoryDetailScreen> {
  late FoodsHistory _history;
  final HistoryRepository _repository = HistoryRepository();
  bool _isRating = false;
  String? _selectedMall;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
  }

  List<String> get _mallNames {
    final Set<String> malls = {'전체'};
    for (var product in _history.recommendations) {
      malls.add(product.mallName);
    }
    return malls.toList();
  }

  List<FoodsProduct> get _filteredProducts {
    if (_selectedMall == null || _selectedMall == '전체') {
      return _history.recommendations;
    }
    return _history.recommendations.where((p) => p.mallName == _selectedMall).toList();
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required int count,
    List<Widget>? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                '$title $count개',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (trailing != null) ...trailing,
            ],
          ),
          if (trailing != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: _mallNames.map((mall) {
                  final isSelected = _selectedMall == mall || (mall == '전체' && _selectedMall == null);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMall = mall == '전체' ? null : mall;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black87 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mall,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
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
            // 추천이유, 간단 조리법, 식재료 추천 섹션
            if (_history.suggestionReason != null || _history.recipeSummary != null || _history.requiredIngredients.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_history.suggestionReason != null)
                      _buildExpandableSection(
                        title: '알프레드의 추천이유',
                        content: _history.suggestionReason!,
                        icon: Icons.lightbulb_outline,
                        isExpanded: false,
                        onExpansionChanged: (_) {},
                      ),
                    if (_history.suggestionReason != null && (_history.recipeSummary != null || _history.requiredIngredients.isNotEmpty))
                      const SizedBox(height: 16),
                    if (_history.recipeSummary != null)
                      _buildExpandableSection(
                        title: '알프레드의 간단 조리법',
                        content: _history.recipeSummary!,
                        icon: Icons.restaurant_menu,
                        isRecipe: true,
                        isExpanded: false,
                        onExpansionChanged: (_) {},
                      ),
                    if (_history.recipeSummary != null && _history.requiredIngredients.isNotEmpty)
                      const SizedBox(height: 16),
                    if (_history.requiredIngredients.isNotEmpty)
                      _buildExpandableSection(
                        title: '알프레드의 식재료 추천',
                        content: _history.requiredIngredients.join(', '),
                        icon: Icons.shopping_basket,
                        isExpanded: false,
                        onExpansionChanged: (_) {},
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // 추천 상품 섹션
            if (hasRecommendations) Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    title: '추천 상품',
                    icon: Icons.shopping_cart_outlined,
                    count: _filteredProducts.length,
                    trailing: const [],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 280,
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _ProductGridItem(
                          imageUrl: product.productImage,
                          name: product.productName,
                          price: product.productPrice,
                          mallName: product.mallName,
                          reviewCount: product.reviewCount,
                          description: product.productDescription,
                          onTap: () { /* 상세 이동 */ },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 추천 레시피 섹션
            if (hasRecipes) Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    title: '추천 레시피',
                    icon: Icons.restaurant_menu,
                    count: _history.recipes.length,
                    trailing: null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 240,
                      ),
                      itemCount: _history.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _history.recipes[index];
                        return _RecipeGridItem(
                          imageUrl: recipe.recipeImage,
                          name: recipe.recipeName,
                          rating: recipe.averageRating.toDouble(),
                          viewCount: recipe.viewCount,
                          onTap: () {
                            // TODO: 레시피 상세 페이지로 이동
                          },
                        );
                      },
                    ),
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

  Widget _buildExpandableSection({
    required String title,
    required String content,
    required IconData icon,
    bool isRecipe = false,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
  }) {
    return Card(
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
              Icon(icon, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 24, thickness: 1),
            if (isRecipe)
              Column(
                children: content
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .split(RegExp(r'\s*\d+\.\s*'))
                    .where((step) => step.isNotEmpty)
                    .map((step) => step.trim())
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content
                    .split(',')
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.trim(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
} 