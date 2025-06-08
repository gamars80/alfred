import 'package:flutter/material.dart';
import '../../model/product.dart';
import 'food_product_card.dart';

class FoodProductsGrid extends StatelessWidget {
  final Map<String, List<Product>> products;
  final String? recipeSummary;

  const FoodProductsGrid({
    super.key,
    required this.products,
    this.recipeSummary,
  });

  @override
  Widget build(BuildContext context) {
    // 모든 상품을 하나의 리스트로 합치기
    final allProducts = products.values.expand((products) => products).toList();

    return Column(
      children: [
        if (recipeSummary != null) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          '간단 조리법',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      recipeSummary!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
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