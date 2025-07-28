// 🎨 Modern Foods History Card - Redesigned with enhanced UI/UX
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/foods_history.dart';

// 🎨 Modern Design System
class FoodsHistoryCardTheme {
  static const Color primaryGradientStart = Color(0xFFed8936);
  static const Color primaryGradientEnd = Color(0xFFdd6b20);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color tagBackground = Color(0xFFed8936);
  static const Color tagText = Color(0xFFffffff);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color starColor = Color(0xFFfbbf24);
  static const Color productColor = Color(0xFF3182ce);
  static const Color recipeColor = Color(0xFF38a169);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class FoodsHistoryCard extends StatefulWidget {
  final FoodsHistory history;
  final VoidCallback onTap;

  const FoodsHistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FoodsHistoryCard> createState() => _FoodsHistoryCardState();
}

class _FoodsHistoryCardState extends State<FoodsHistoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: FoodsHistoryCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _extractTag() {
    if (widget.history.ingredients?.isNotEmpty ?? false) {
      final ingredients = widget.history.ingredients!;
      if (ingredients.startsWith('[') && ingredients.endsWith(']')) {
        // [] 제거하고 반환
        final content = ingredients.substring(1, ingredients.length - 1).trim();
        // content가 비어있거나 "[]"인 경우 suggested 값을 사용
        if (content.isEmpty || content == "[]") {
          return widget.history.suggested;
        }
        return content.isNotEmpty ? content : null;
      }
      return ingredients;
    } else if (widget.history.suggested?.isNotEmpty ?? false) {
      return widget.history.suggested;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tag = _extractTag();
    final hasRecommendations = widget.history.recommendations.isNotEmpty;
    final hasRecipes = widget.history.recipes.isNotEmpty;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  _animationController.reverse().then((_) {
                    widget.onTap();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: FoodsHistoryCardTheme.cardBackground,
                    borderRadius: BorderRadius.circular(FoodsHistoryCardTheme.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(FoodsHistoryCardTheme.borderRadius),
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.history.query ?? '음식 추천',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: FoodsHistoryCardTheme.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildStatusChip(widget.history.status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Tag
                            if (tag != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      FoodsHistoryCardTheme.primaryGradientStart,
                                      FoodsHistoryCardTheme.primaryGradientEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FoodsHistoryCardTheme.primaryGradientStart.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: FoodsHistoryCardTheme.tagText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Info chips
                            if (hasRecommendations || hasRecipes) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (hasRecommendations)
                                    _buildInfoChip(
                                      Icons.shopping_cart_outlined,
                                      '${widget.history.recommendations.length}개의 상품',
                                      FoodsHistoryCardTheme.productColor,
                                    ),
                                  if (hasRecipes)
                                    _buildInfoChip(
                                      Icons.restaurant_menu,
                                      '${widget.history.recipes.length}개의 레시피',
                                      FoodsHistoryCardTheme.recipeColor,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Rating and date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Rating stars
                                Row(
                                  children: List.generate(5, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Icon(
                                        (widget.history.hasRating && widget.history.myRating != null && index < widget.history.myRating!) 
                                            ? Icons.star 
                                            : Icons.star_border,
                                        size: 20,
                                        color: FoodsHistoryCardTheme.starColor,
                                      ),
                                    );
                                  }),
                                ),
                                
                                // Date
                                Text(
                                  DateFormat('yyyy.MM.dd HH:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(widget.history.createdAt),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: FoodsHistoryCardTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Arrow indicator
                            const SizedBox(height: 12),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    final isWaiting = status == 'WAITING';
    final color = isWaiting ? FoodsHistoryCardTheme.warningColor : FoodsHistoryCardTheme.successColor;
    final text = isWaiting ? '처리대기중' : '완료';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 