import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import '../../model/keyword_review.dart';
import '../../../../common/widget/rating_stars.dart';

class KeywordReviewCard extends StatefulWidget {
  final KeywordReview review;

  const KeywordReviewCard({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  State<KeywordReviewCard> createState() => _KeywordReviewCardState();
}

class _KeywordReviewCardState extends State<KeywordReviewCard> {
  static const int maxTextLength = 100;
  bool _isExpanded = false;

  Future<void> _launchReviewUrl(BuildContext context) async {
    final url = Uri.parse('https://web.babitalk.com/reviews/${widget.review.reviewId}');

    try {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰 페이지를 열 수 없습니다.')),
        );
      }
    }
  }

  String get _displayText {
    if (widget.review.text.length <= maxTextLength || _isExpanded) {
      return widget.review.text;
    }
    return '${widget.review.text.substring(0, maxTextLength)}...';
  }

  bool get _shouldShowMoreButton => widget.review.text.length > maxTextLength;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Row(
              children: [
                RatingStars(rating: widget.review.rating),
                const SizedBox(width: 8),
                Text(
                  widget.review.rating.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            if (widget.review.images.isNotEmpty) 
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildImages(),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayText,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (_shouldShowMoreButton)
                    GestureDetector(
                      onTap: () => _launchReviewUrl(context),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _isExpanded ? '접기' : '더보기',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.review.doctor != null)
            Row(
              children: [
                if (widget.review.doctor?.profilePhoto != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.review.doctor!.profilePhoto!),
                      backgroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.review.doctor!.name} ${widget.review.doctor!.position}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
            ),
          if (widget.review.event != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (widget.review.event!.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.review.event!.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.review.event!.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          widget.review.event!.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.review.event!.discountPrice != null) ...[
                              Text(
                                '${(((widget.review.event!.price - widget.review.event!.discountPrice!) / widget.review.event!.price) * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.review.event!.discountPrice! ~/ 10000}만원',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (widget.review.event!.includeVat)
                              Text(
                                ' (VAT포함)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImages() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.review.images.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final image = widget.review.images[index];
          return GestureDetector(
            onTap: () => _launchReviewUrl(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withAlpha(50),
                      BlendMode.darken,
                    ),
                    child: Image.network(
                      image.isBlur ? image.smallUrl : image.url,
                      height: 104,
                      width: 104,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 