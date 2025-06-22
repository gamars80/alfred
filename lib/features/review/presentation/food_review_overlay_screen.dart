import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../call/model/product.dart';
import '../data/review_repository.dart';
import '../model/review.dart';

class FoodReviewOverlayScreen extends StatefulWidget {
  final Product product;

  const FoodReviewOverlayScreen({super.key, required this.product});

  @override
  State<FoodReviewOverlayScreen> createState() => _FoodReviewOverlayScreenState();
}

class _FoodReviewOverlayScreenState extends State<FoodReviewOverlayScreen> {
  final repo = ReviewRepository();
  late Future<List<Review>> reviewsFuture;
  final Map<int, bool> _expandedReviews = {};

  @override
  void initState() {
    super.initState();
    debugPrint(widget.product.source);
    reviewsFuture = repo.fetchFoodReviews(
      productId: widget.product.productId,
      source: widget.product.source!,
    );
  }

  void _showImageViewer(BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _ImageViewerDialog(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  '리뷰',
                  style: TextStyle(
                    color: Color(0xFF2B2B2B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF2B2B2B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF8F9FA),
                child: FutureBuilder<List<Review>>(
                  future: reviewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                          strokeWidth: 2,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFE91E63),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '리뷰를 불러올 수 없습니다',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final reviews = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, i) {
                        final review = reviews[i];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (review.rating > 0) ...[
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (j) => Padding(
                                          padding: const EdgeInsets.only(right: 1),
                                          child: Icon(
                                            j < review.rating
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: j < review.rating
                                                ? const Color(0xFFFFB400)
                                                : const Color(0xFFE0E0E0),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${review.rating}.0',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF616161),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final hasImages = review.imageUrls.isNotEmpty;
                                    final contentWidth = hasImages 
                                        ? constraints.maxWidth - 100 
                                        : constraints.maxWidth;
                                    
                                    final textPainter = TextPainter(
                                      text: TextSpan(
                                        text: review.content,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                      maxLines: 3,
                                      textDirection: TextDirection.ltr,
                                    );
                                    textPainter.layout(maxWidth: contentWidth);
                                    
                                    final isOverflowing = textPainter.didExceedMaxLines;
                                    final isExpanded = _expandedReviews[i] ?? false;

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AnimatedCrossFade(
                                                firstChild: Text(
                                                  review.content,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF424242),
                                                    height: 1.5,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                secondChild: Text(
                                                  review.content,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF424242),
                                                    height: 1.5,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                crossFadeState: isExpanded
                                                    ? CrossFadeState.showSecond
                                                    : CrossFadeState.showFirst,
                                                duration: const Duration(milliseconds: 200),
                                              ),
                                              if (isOverflowing) ...[
                                                const SizedBox(height: 6),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _expandedReviews[i] = !isExpanded;
                                                    });
                                                  },
                                                  child: Text(
                                                    isExpanded ? '접기' : '더보기',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFE91E63),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (hasImages && isExpanded) ...[
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                  height: 80,
                                                  child: ListView.separated(
                                                    scrollDirection: Axis.horizontal,
                                                    physics: const BouncingScrollPhysics(),
                                                    itemCount: review.imageUrls.length,
                                                    separatorBuilder: (context, index) =>
                                                        const SizedBox(width: 8),
                                                    itemBuilder: (context, index) {
                                                      return GestureDetector(
                                                        onTap: () => _showImageViewer(
                                                          context,
                                                          review.imageUrls,
                                                          index,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: CachedNetworkImage(
                                                            imageUrl: review.imageUrls[index],
                                                            width: 80,
                                                            height: 80,
                                                            fit: BoxFit.cover,
                                                            placeholder: (_, __) => Container(
                                                              color: const Color(0xFFF5F5F5),
                                                              child: const Center(
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                  color: Color(0xFFE91E63),
                                                                ),
                                                              ),
                                                            ),
                                                            errorWidget: (_, __, ___) =>
                                                                Container(
                                                              color: const Color(0xFFF5F5F5),
                                                              child: const Icon(
                                                                Icons.image_not_supported_outlined,
                                                                color: Color(0xFFBDBDBD),
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (hasImages && !isExpanded) ...[
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: () => _showImageViewer(
                                              context,
                                              review.imageUrls,
                                              0,
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl: review.imageUrls[0],
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, __) => Container(
                                                      color: const Color(0xFFF5F5F5),
                                                      child: const Center(
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Color(0xFFE91E63),
                                                        ),
                                                      ),
                                                    ),
                                                    errorWidget: (_, __, ___) =>
                                                        Container(
                                                      color: const Color(0xFFF5F5F5),
                                                      child: const Icon(
                                                        Icons.image_not_supported_outlined,
                                                        color: Color(0xFFBDBDBD),
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (review.imageUrls.length > 1)
                                                  Positioned(
                                                    right: 4,
                                                    bottom: 4,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.7),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        '+${review.imageUrls.length - 1}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewerDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImageViewerDialog({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 