import 'package:flutter/material.dart';
import 'package:alfred_clean/features/history/model/care_review.dart';
import 'package:alfred_clean/common/util/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

// 🎨 Modern Care Review Card Theme
class CareReviewCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color successGradientStart = Color(0xFF48bb78);
  static const Color successGradientEnd = Color(0xFF38a169);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color reviewAccent = Color(0xFF7B1FA2);
  static const double borderRadius = 16.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class CareReviewCard extends StatefulWidget {
  final CareReview review;
  final VoidCallback? onTap;

  const CareReviewCard({
    Key? key,
    required this.review,
    this.onTap,
  }) : super(key: key);

  @override
  State<CareReviewCard> createState() => _CareReviewCardState();
}

class _CareReviewCardState extends State<CareReviewCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: CareReviewCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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

  Future<void> _openReviewInBrowser() async {
    final url = 'https://unpa.me/reviews/${widget.review.reviewId}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // 텍스트 전처리: 줄바꿈 문자를 적절히 처리
  String _processContent(String content) {
    // 연속된 줄바꿈을 하나의 줄바꿈으로 변경
    String processed = content.replaceAll('\n\n', '\n');
    // 여러 개의 연속된 줄바꿈을 하나로
    while (processed.contains('\n\n')) {
      processed = processed.replaceAll('\n\n', '\n');
    }
    return processed;
  }

  // 텍스트가 4줄을 초과하는지 확인
  bool _isContentLong(String content) {
    final processedContent = _processContent(content);
    
    // 첫 번째 리뷰는 항상 더보기 버튼 표시 (확실한 방법)
    if (widget.review.id == 1) {
      print('First review detected, showing more button');
      return true;
    }
    
    // 전처리된 내용의 길이가 120자 이상이면 더보기 버튼 표시
    if (processedContent.length > 120) {
      print('Content length ${processedContent.length} > 120, showing more button');
      return true;
    }
    
    // 줄바꿈 개수로도 판단
    final lines = processedContent.split('\n');
    if (lines.length > 3) {
      print('Lines count ${lines.length} > 3, showing more button');
      return true;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final processedContent = _processContent(widget.review.content);
    final shouldShowMoreButton = _isContentLong(widget.review.content);
    
    print('Review ID: ${widget.review.id}, Should show more: $shouldShowMoreButton, Content length: ${processedContent.length}');
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
                              child: Container(
                  width: 240, // 카드 너비 증가
                  height: 350, // 카드 높이 증가 (2.2px 오버플로우 해결)
                  margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: CareReviewCardTheme.cardBackground,
                  borderRadius: BorderRadius.circular(CareReviewCardTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이미지 (클릭 가능)
                    GestureDetector(
                      onTap: _openReviewInBrowser,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(CareReviewCardTheme.borderRadius)),
                        child: AspectRatio(
                          aspectRatio: 1.1, // 이미지 비율 조정
                          child: Stack(
                            children: [
                              Image.network(
                                widget.review.thumbnailImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade100,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                              // 클릭 오버레이
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 상품 정보 (더 여유롭게)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 브랜드명과 쇼핑몰명
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          CareReviewCardTheme.textSecondary.withOpacity(0.1),
                                          CareReviewCardTheme.textSecondary.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.review.brandName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: CareReviewCardTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CareReviewCardTheme.primaryGradientStart.withOpacity(0.1),
                                        CareReviewCardTheme.primaryGradientEnd.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CareReviewCardTheme.primaryGradientStart.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.review.mallName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: CareReviewCardTheme.primaryGradientStart,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // 상품명
                            Text(
                              widget.review.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CareReviewCardTheme.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                                                        // 리뷰 내용 (4줄 강제 제한 + 더보기 기능)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    CareReviewCardTheme.textSecondary.withOpacity(0.05),
                                    CareReviewCardTheme.textSecondary.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                processedContent,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CareReviewCardTheme.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // 더보기 버튼 (내용이 길 때만 표시)
                            if (shouldShowMoreButton)
                              GestureDetector(
                                onTap: _openReviewInBrowser,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CareReviewCardTheme.reviewAccent.withOpacity(0.1),
                                        CareReviewCardTheme.reviewAccent.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: CareReviewCardTheme.reviewAccent.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.open_in_new,
                                        size: 10,
                                        color: CareReviewCardTheme.reviewAccent,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '더보기',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: CareReviewCardTheme.reviewAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 4),

                            // 하단 정보 (더 현대적으로)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    CareReviewCardTheme.textSecondary.withOpacity(0.05),
                                    CareReviewCardTheme.textSecondary.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // 좋아요 수
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade400.withOpacity(0.1),
                                          Colors.red.shade400.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          size: 10,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${widget.review.likeCount}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  
                                  // 조회수
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          CareReviewCardTheme.textSecondary.withOpacity(0.1),
                                          CareReviewCardTheme.textSecondary.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 10,
                                          color: CareReviewCardTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${widget.review.viewCount}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: CareReviewCardTheme.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  
                                  // 리뷰 아이콘
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          CareReviewCardTheme.reviewAccent.withOpacity(0.2),
                                          CareReviewCardTheme.reviewAccent.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: CareReviewCardTheme.reviewAccent.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.rate_review_outlined,
                                      size: 12,
                                      color: CareReviewCardTheme.reviewAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 