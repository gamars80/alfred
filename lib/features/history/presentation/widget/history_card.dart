// 🎨 Modern History Card - Redesigned with enhanced UI/UX
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/recommendation_history.dart';

// 🎨 Modern Design System
class HistoryCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color tagBackground = Color(0xFF667eea);
  static const Color tagText = Color(0xFFffffff);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color starColor = Color(0xFFfbbf24);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class HistoryCard extends StatefulWidget {
  final RecommendationHistory history;
  final List<String> Function(String) extractTags;
  final VoidCallback onTap;

  const HistoryCard({
    Key? key,
    required this.history,
    required this.extractTags,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: HistoryCardTheme.animationDuration,
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

  @override
  Widget build(BuildContext context) {
    final List<String> tags = [];
    tags.add('#${widget.history.gender}');
    tags.add('#${widget.history.age}');
    if (widget.history.itemType != null) tags.add('#${widget.history.itemType!}');
    if (widget.history.useCase != null) tags.add('#${widget.history.useCase!}');
    if (widget.history.season != null) tags.add('#${widget.history.season!}');
    
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
                    color: HistoryCardTheme.cardBackground,
                    borderRadius: BorderRadius.circular(HistoryCardTheme.borderRadius),
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
                      borderRadius: BorderRadius.circular(HistoryCardTheme.borderRadius),
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
                                    widget.history.query,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: HistoryCardTheme.textPrimary,
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
                            
                            // Tags
                            if (tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          HistoryCardTheme.primaryGradientStart,
                                          HistoryCardTheme.primaryGradientEnd,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: HistoryCardTheme.primaryGradientStart.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: HistoryCardTheme.tagText,
                                      ),
                                    ),
                                  );
                                }).toList(),
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
                                        color: HistoryCardTheme.starColor,
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
                                    color: HistoryCardTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            

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
    final color = isWaiting ? HistoryCardTheme.warningColor : HistoryCardTheme.successColor;
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
}


