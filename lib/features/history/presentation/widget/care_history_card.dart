// 🎨 Modern Care History Card - Redesigned with enhanced UI/UX
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/care_history.dart';

// 🎨 Modern Design System
class CareHistoryCardTheme {
  static const Color primaryGradientStart = Color(0xFF48bb78);
  static const Color primaryGradientEnd = Color(0xFF38a169);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color tagBackground = Color(0xFF48bb78);
  static const Color tagText = Color(0xFFffffff);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const Color starColor = Color(0xFFfbbf24);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class CareHistoryCard extends StatefulWidget {
  final CareHistory history;
  final VoidCallback onTap;

  const CareHistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CareHistoryCard> createState() => _CareHistoryCardState();
}

class _CareHistoryCardState extends State<CareHistoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: CareHistoryCardTheme.animationDuration,
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
                    color: CareHistoryCardTheme.cardBackground,
                    borderRadius: BorderRadius.circular(CareHistoryCardTheme.borderRadius),
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
                      borderRadius: BorderRadius.circular(CareHistoryCardTheme.borderRadius),
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
                                      color: CareHistoryCardTheme.textPrimary,
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
                            
                            // Keyword tag
                            if (widget.history.keyword.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      CareHistoryCardTheme.primaryGradientStart,
                                      CareHistoryCardTheme.primaryGradientEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CareHistoryCardTheme.primaryGradientStart.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.history.keyword,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: CareHistoryCardTheme.tagText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Info row
                            Row(
                              children: [
                                // Time icon and date
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CareHistoryCardTheme.primaryGradientStart.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: CareHistoryCardTheme.primaryGradientStart,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('yyyy.MM.dd HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(widget.history.createdAt),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CareHistoryCardTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Product count
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: CareHistoryCardTheme.primaryGradientStart.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: CareHistoryCardTheme.primaryGradientStart.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag,
                                        size: 14,
                                        color: CareHistoryCardTheme.primaryGradientStart,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.history.recommendations.length}개 상품',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: CareHistoryCardTheme.primaryGradientStart,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Rating (if exists)
                            if (widget.history.hasRating && widget.history.myRating != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: CareHistoryCardTheme.starColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '평점: ${widget.history.myRating}/5',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: CareHistoryCardTheme.starColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'FINISH':
        return CareHistoryCardTheme.successColor;
      case 'PROCESSING':
        return CareHistoryCardTheme.warningColor;
      case 'FAILED':
        return CareHistoryCardTheme.errorColor;
      default:
        return CareHistoryCardTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'FINISH':
        return '완료';
      case 'PROCESSING':
        return '처리중';
      case 'FAILED':
        return '실패';
      default:
        return '대기중';
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    
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