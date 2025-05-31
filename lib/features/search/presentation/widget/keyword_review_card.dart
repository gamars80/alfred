import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import '../../../call/presentation/event_webview_screen.dart';
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
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰 페이지를 열 수 없습니다.')),
        );
      }
    }
  }

  // Future<void> _launchEventUrl(BuildContext context) async {
  //   final url = 'https://web.babitalk.com/events/${widget.review.event!.id}';
  //   debugPrint("url::::::::::::::::::::::::$url");
  //   if (context.mounted) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => EventWebViewScreen(url: url),
  //       ),
  //     );
  //   }
  // }

  Future<void> _launchEventUrl(BuildContext context) async {
    final url = Uri.parse('https://web.babitalk.com/events/${widget.review.event!.id}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이벤트 페이지를 열 수 없습니다.')),
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

  /// 흐리게 + 블라인드 패턴 효과
  Widget _buildImageBlind(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 153),
              Colors.white,
              Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 153),
            ],
            stops: [0.0, 0.25, 0.5, 0.75],
            tileMode: TileMode.repeated,
            transform: const GradientRotation(90 * 3.1416 / 180),
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Image.network(
            url,
            width: 104,
            height: 104,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ),
    );
  }

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
                    style: TextStyle(fontSize: 10, height: 1.4, color: Colors.grey.shade800),
                  ),
                  if (_shouldShowMoreButton)
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _isExpanded ? '접기' : '더보기',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
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
                if (widget.review.doctor!.profilePhoto != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 1),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade900),
                  ),
                ),
              ],
            ),
          if (widget.review.event != null) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (widget.review.event!.image != null)
                    GestureDetector(
                      onTap: () => _launchEventUrl(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.review.event!.image!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.review.event!.name,
                          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (widget.review.event!.discountPrice != null) ...[
                              Text(
                                '${(((widget.review.event!.price - widget.review.event!.discountPrice!) / widget.review.event!.price) * 100).round()}%',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.red.shade700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.review.event!.discountPrice! ~/ 10000}만원',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              if (widget.review.event!.includeVat)
                                Text(
                                  ' (VAT포함)',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                            ],
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final img = widget.review.images[index];
          return GestureDetector(
            onTap: () => _launchReviewUrl(context),
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 1)],
              ),
              child: _buildImageBlind(img.isBlur ? img.smallUrl : img.url),
            ),
          );
        },
      ),
    );
  }
}
