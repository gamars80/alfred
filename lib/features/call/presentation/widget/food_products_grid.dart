import 'dart:io';

import 'package:flutter/material.dart';
import '../../model/product.dart';
import 'food_product_card.dart';

// 🎨 Modern Food Products Grid Theme
class FoodProductsGridTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color successGradientStart = Color(0xFF48bb78);
  static const Color successGradientEnd = Color(0xFF38a169);
  static const Color warningGradientStart = Color(0xFFed8936);
  static const Color warningGradientEnd = Color(0xFFdd6b20);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const double borderRadius = 16.0;
  static const double cardElevation = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class FoodProductsGrid extends StatefulWidget {
  final Map<String, List<Product>> products;
  final String? recipeSummary;
  final String? requiredIngredients;
  final String? suggestionReason;
  final int historyId;

  const FoodProductsGrid({
    super.key,
    required this.products,
    required this.historyId,
    this.recipeSummary,
    this.requiredIngredients,
    this.suggestionReason,
  });

  @override
  State<FoodProductsGrid> createState() => _FoodProductsGridState();
}

class _FoodProductsGridState extends State<FoodProductsGrid> with TickerProviderStateMixin {
  bool _isRecipeExpanded = false;
  bool _isIngredientsExpanded = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: FoodProductsGridTheme.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

    // 디버깅을 위한 로그 추가
    print('recipeSummary: "${widget.recipeSummary}"');
    print('requiredIngredients: "${widget.requiredIngredients}"');
    print('suggestionReason: "${widget.suggestionReason}"');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((widget.recipeSummary != null && widget.recipeSummary!.trim().isNotEmpty && widget.recipeSummary!.trim() != '[]') || 
                   (widget.requiredIngredients != null && widget.requiredIngredients!.trim().isNotEmpty && widget.requiredIngredients!.trim() != '[]') || 
                   (widget.suggestionReason != null && widget.suggestionReason!.trim().isNotEmpty && widget.suggestionReason!.trim() != '[]'))
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (widget.suggestionReason != null && widget.suggestionReason!.trim().isNotEmpty && widget.suggestionReason!.trim() != '[]')
                        _buildModernExpandableSection(
                          title: '알프레드의 추천이유',
                          content: widget.suggestionReason!,
                          icon: Icons.lightbulb_outline,
                          gradientColors: [FoodProductsGridTheme.warningGradientStart, FoodProductsGridTheme.warningGradientEnd],
                          isExpanded: false,
                          onExpansionChanged: (_) {},
                        ),
                      if ((widget.suggestionReason != null && widget.suggestionReason!.trim().isNotEmpty && widget.suggestionReason!.trim() != '[]') && 
                           ((widget.recipeSummary != null && widget.recipeSummary!.trim().isNotEmpty && widget.recipeSummary!.trim() != '[]') || 
                            (widget.requiredIngredients != null && widget.requiredIngredients!.trim().isNotEmpty && widget.requiredIngredients!.trim() != '[]')))
                        const SizedBox(height: 16),
                      if (widget.recipeSummary != null && widget.recipeSummary!.trim().isNotEmpty && widget.recipeSummary!.trim() != '[]')
                        _buildModernExpandableSection(
                          title: '알프레드의 간단 조리법',
                          content: widget.recipeSummary!,
                          icon: Icons.restaurant_menu,
                          gradientColors: [FoodProductsGridTheme.successGradientStart, FoodProductsGridTheme.successGradientEnd],
                          isRecipe: true,
                          isExpanded: _isRecipeExpanded,
                          onExpansionChanged: (value) => setState(() => _isRecipeExpanded = value),
                        ),
                      if ((widget.recipeSummary != null && widget.recipeSummary!.trim().isNotEmpty && widget.recipeSummary!.trim() != '[]') && 
                           (widget.requiredIngredients != null && widget.requiredIngredients!.trim().isNotEmpty && widget.requiredIngredients!.trim() != '[]'))
                        const SizedBox(height: 16),
                      if (widget.requiredIngredients != null && widget.requiredIngredients!.trim().isNotEmpty && widget.requiredIngredients!.trim() != '[]')
                        _buildModernExpandableSection(
                          title: '알프레드의 식재료 추천',
                          content: widget.requiredIngredients!,
                          icon: Icons.shopping_basket,
                          gradientColors: [FoodProductsGridTheme.primaryGradientStart, FoodProductsGridTheme.primaryGradientEnd],
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
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FoodProductsGridTheme.secondaryGradientStart.withOpacity(0.1),
                              FoodProductsGridTheme.secondaryGradientEnd.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(FoodProductsGridTheme.borderRadius),
                          border: Border.all(
                            color: FoodProductsGridTheme.secondaryGradientStart.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FoodProductsGridTheme.secondaryGradientStart,
                                    FoodProductsGridTheme.secondaryGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: FoodProductsGridTheme.secondaryGradientStart.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_mall_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '추천 상품 ${allProducts.length}개',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: FoodProductsGridTheme.textPrimary,
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: Platform.isIOS ? 260 : 240
                ),
                itemCount: allProducts.length,
                itemBuilder: (context, index) => FoodProductCard(product: allProducts[index], historyId: widget.historyId),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernExpandableSection({
    required String title,
    required String content,
    required IconData icon,
    required List<Color> gradientColors,
    bool isRecipe = false,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FoodProductsGridTheme.cardBackground,
        borderRadius: BorderRadius.circular(FoodProductsGridTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: FoodProductsGridTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.2),
                    gradientColors[1].withOpacity(0.2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
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
                              fontSize: 11,
                              height: 1.5,
                              color: FoodProductsGridTheme.textPrimary,
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
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0].withOpacity(0.1),
                                gradientColors[1].withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: gradientColors[0].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.trim(),
                            style: TextStyle(
                              fontSize: 11,
                              color: gradientColors[0],
                              fontWeight: FontWeight.w600,
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