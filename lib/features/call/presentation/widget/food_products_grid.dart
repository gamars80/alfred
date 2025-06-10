import 'package:flutter/material.dart';
import '../../model/product.dart';
import 'food_product_card.dart';

class FoodProductsGrid extends StatefulWidget {
  final Map<String, List<Product>> products;
  final String? recipeSummary;
  final String? requiredIngredients;
  final String? suggestionReason;

  const FoodProductsGrid({
    super.key,
    required this.products,
    this.recipeSummary,
    this.requiredIngredients,
    this.suggestionReason,
  });

  @override
  State<FoodProductsGrid> createState() => _FoodProductsGridState();
}

class _FoodProductsGridState extends State<FoodProductsGrid> {
  bool _isRecipeExpanded = false;
  bool _isIngredientsExpanded = false;

  String _formatText(String text, {bool isRecipe = false}) {
    if (text.startsWith('[') && text.endsWith(']')) {
      text = text.substring(1, text.length - 1);
    }
    
    if (isRecipe) {
      final steps = text.split(RegExp(r'\s*\d+\.\s*'))
          .where((step) => step.isNotEmpty)
          .map((step) => step.trim())
          .toList();
      
      return steps.asMap()
          .map((index, step) => MapEntry(index, '${index + 1}. $step'))
          .values
          .join('\n');
    } else {
      return text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).join(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = widget.products.values.expand((products) => products).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.recipeSummary != null || widget.requiredIngredients != null || widget.suggestionReason != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (widget.suggestionReason != null)
                  _buildExpandableSection(
                    title: '알프레드의 추천이유',
                    content: widget.suggestionReason!,
                    icon: Icons.lightbulb_outline,
                    isExpanded: false,
                    onExpansionChanged: (_) {},
                  ),
                if (widget.suggestionReason != null && (widget.recipeSummary != null || widget.requiredIngredients != null))
                  const SizedBox(height: 16),
                if (widget.recipeSummary != null)
                  _buildExpandableSection(
                    title: '알프레드의 간단 조리법',
                    content: widget.recipeSummary!,
                    icon: Icons.restaurant_menu,
                    isRecipe: true,
                    isExpanded: _isRecipeExpanded,
                    onExpansionChanged: (value) => setState(() => _isRecipeExpanded = value),
                  ),
                if (widget.recipeSummary != null && widget.requiredIngredients != null)
                  const SizedBox(height: 16),
                if (widget.requiredIngredients != null)
                  _buildExpandableSection(
                    title: '알프레드의 식재료 추천',
                    content: widget.requiredIngredients!,
                    icon: Icons.shopping_basket,
                    isExpanded: _isIngredientsExpanded,
                    onExpansionChanged: (value) => setState(() => _isIngredientsExpanded = value),
                  ),
              ],
            ),
          ),
        if (allProducts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_mall_outlined,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '추천 상품 ${allProducts.length}개',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 9,
            mainAxisSpacing: 11,
            // 이 높이(예: 260) 이하로는 안 작아지기 때문에 overflow 걱정 끝!
            mainAxisExtent: 265
          ),
          itemCount: allProducts.length,
          itemBuilder: (context, index) => FoodProductCard(product: allProducts[index]),
        ),
        const SizedBox(height: 16),
      ],
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
                children: _formatText(content)
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