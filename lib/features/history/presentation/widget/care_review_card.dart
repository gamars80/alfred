import 'package:flutter/material.dart';
import 'package:alfred_clean/features/history/model/care_review.dart';
import 'package:alfred_clean/common/util/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _CareReviewCardState extends State<CareReviewCard> {
  bool _isExpanded = false;

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
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        // height: 280, // 카드 높이를 줄여서 더 콤팩트하게
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1.2, // 이미지 비율을 더 넓게 조정
                  child: Image.network(
                    widget.review.thumbnailImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // 상품 정보 (더 콤팩트하게)
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
                          child: Text(
                            widget.review.brandName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.review.mallName,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    
                    // 상품명
                    Text(
                      widget.review.productName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    
                    // 리뷰 내용 (4줄 강제 제한 + 더보기 기능)
                    Text(
                      processedContent,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // 더보기 버튼 (내용이 길 때만 표시)
                    if (shouldShowMoreButton)
                      GestureDetector(
                        onTap: _openReviewInBrowser,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '더보기',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7B1FA2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // 하단 정보 (더 콤팩트하게)
                    Row(
                      children: [
                        // 좋아요 수
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 10,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.review.likeCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        
                        // 조회수
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 10,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.review.viewCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        
                        // 리뷰 아이콘
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.rate_review_outlined,
                            size: 10,
                            color: Color(0xFF7B1FA2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 