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
      // 식재료의 경우 쉼표로 구분
      return text.split(',').map((item) => item.trim()).join('\n');
    }
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
            Text(
              _formatText(content, isRecipe: isRecipe),
              style: const TextStyle(
                fontSize: 14,
                height: 1.8,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = products.values.expand((products) => products).toList();

    return Column(
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: allProducts.length,
            itemBuilder: (context, index) {
              return FoodProductCard(product: allProducts[index]);
            },
          ),
        ),
      ],
    );
  }
} 