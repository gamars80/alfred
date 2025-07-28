// 🎨 Modern Beauty History Card - Redesigned with enhanced UI/UX
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/beauty_history.dart';

// 🎨 Modern Design System
class BeautyHistoryCardTheme {
  static const Color primaryGradientStart = Color(0xFFf093fb);
  static const Color primaryGradientEnd = Color(0xFFf5576c);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color tagBackground = Color(0xFFf093fb);
  static const Color tagText = Color(0xFFffffff);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class BeautyHistoryCard extends StatefulWidget {
  final BeautyHistory history;
  final VoidCallback onTap;

  const BeautyHistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BeautyHistoryCard> createState() => _BeautyHistoryCardState();
}

class _BeautyHistoryCardState extends State<BeautyHistoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: BeautyHistoryCardTheme.animationDuration,
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
    final date = DateFormat('yyyy.MM.dd HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(widget.history.createdAt),
    );

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
                    color: BeautyHistoryCardTheme.cardBackground,
                    borderRadius: BorderRadius.circular(BeautyHistoryCardTheme.borderRadius),
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
                      borderRadius: BorderRadius.circular(BeautyHistoryCardTheme.borderRadius),
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: BeautyHistoryCardTheme.primaryGradientStart.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: BeautyHistoryCardTheme.primaryGradientStart,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BeautyHistoryCardTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Keyword tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    BeautyHistoryCardTheme.primaryGradientStart,
                                    BeautyHistoryCardTheme.primaryGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: BeautyHistoryCardTheme.primaryGradientStart.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '#${widget.history.keyword}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BeautyHistoryCardTheme.tagText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Query text
                            Text(
                              widget.history.query,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: BeautyHistoryCardTheme.textPrimary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
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
}
