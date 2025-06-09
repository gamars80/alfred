import 'package:flutter/material.dart';
import '../../model/product.dart';
import 'food_product_card.dart';

class FoodProductsGrid extends StatelessWidget {
  final Map<String, List<Product>> products;
  final String? recipeSummary;
  final String? requiredIngredients;

  const FoodProductsGrid({
    super.key,
    required this.products,
    this.recipeSummary,
    this.requiredIngredients,
  });

  String _formatText(String text, {bool isRecipe = false}) {
    if (text.startsWith('[') && text.endsWith(']')) {
      text = text.substring(1, text.length - 1);
    }
    
    if (isRecipe) {
      // 번호로 시작하는 스텝들을 찾아서 분리
      final steps = text.split(RegExp(r'\s*\d+\.\s*'))
          .where((step) => step.isNotEmpty)
          .map((step) => step.trim())
          .toList();
      
      // 각 스텝 앞에 번호를 다시 붙여서 반환
      return steps.asMap()
          .map((index, step) => MapEntry(index, '${index + 1}. $step'))
          .values
          .join('\n');
    } else {
      // 식재료의 경우 쉼표로 구분하여 리스트로 반환
      return text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).join(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = products.values.expand((products) => products).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipeSummary != null || requiredIngredients != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (recipeSummary != null)
                  _buildSectionCard(
                    title: '알프레드의 간단 조리법',
                    content: recipeSummary!,
                    icon: Icons.restaurant_menu,
                    isRecipe: true,
                  ),
                if (recipeSummary != null && requiredIngredients != null)
                  const SizedBox(height: 16),
                if (requiredIngredients != null)
                  _buildSectionCard(
                    title: '알프레드의 식재료 추천',
                    content: requiredIngredients!,
                    icon: Icons.shopping_basket,
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
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: allProducts.length,
          itemBuilder: (context, index) {
            return FoodProductCard(product: allProducts[index]);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    bool isRecipe = false,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
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
                              fontSize: 14,
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