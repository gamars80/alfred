import 'package:flutter/material.dart';
import '../../model/product.dart';
import 'food_product_card.dart';

class FoodProductsGrid extends StatelessWidget {
  final Map<String, List<Product>> products;

  const FoodProductsGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // 모든 상품을 하나의 리스트로 합치기
    final allProducts = products.values.expand((products) => products).toList();

    return GridView.builder(
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
    );
  }
} 