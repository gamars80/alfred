import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/review.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Review review;

  const ReviewDetailScreen({
    super.key,
    required this.review,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.review.mallName ?? '리뷰',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.review.productName != null)
            GestureDetector(
              onTap: () async {
                if (widget.review.productLink != null) {
                  final uri = Uri.tryParse(widget.review.productLink!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('상품 링크를 열 수 없습니다.')),
                      );
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: widget.review.productImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.review.productImageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey[200]),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.review.productName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.review.productPrice != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '₩${widget.review.productPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.review.imageUrls.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.review.imageUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    );
                  },
                ),
                if (widget.review.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.review.imageUrls.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPage
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.review.selectedOptions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: widget.review.selectedOptions
                          .map((option) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  if (widget.review.content != null &&
                      widget.review.content!.isNotEmpty) ...[
                    if (widget.review.selectedOptions.isNotEmpty)
                      const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.review.content!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 