import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/review.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Review review;
  final List<Review>? allReviews; // 모든 리뷰 목록
  final int? initialIndex; // 초기 인덱스

  const ReviewDetailScreen({
    super.key,
    required this.review,
    this.allReviews,
    this.initialIndex,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final PageController _reviewPageController; // 리뷰 연속 스크롤용
  int _currentReviewPage = 0;
  late List<Review> _reviews;
  late int _initialIndex;

  @override
  void initState() {
    super.initState();
    
    // 리뷰 목록 설정
    if (widget.allReviews != null) {
      _reviews = widget.allReviews!;
      _initialIndex = widget.initialIndex ?? 0;
    } else {
      // 단일 리뷰인 경우
      _reviews = [widget.review];
      _initialIndex = 0;
    }
    
    _reviewPageController = PageController(initialPage: _initialIndex);
    _reviewPageController.addListener(_onReviewPageChanged);
  }

  @override
  void dispose() {
    _reviewPageController.dispose();
    super.dispose();
  }

  void _onReviewPageChanged() {
    final page = _reviewPageController.page?.round() ?? 0;
    if (_currentReviewPage != page) {
      setState(() {
        _currentReviewPage = page;
      });
    }
  }

  String _getProductImageUrl(String imageUrl) {
    // mallName이 'HOTPING'이고 이미지 URL에 스키마가 없는 경우 https:를 추가
    if (widget.review.mallName == 'HOTPING' && 
        !imageUrl.startsWith('https:') && 
        !imageUrl.startsWith('http:')) {
      // //로 시작하는 경우 https:를 앞에 붙임
      if (imageUrl.startsWith('//')) {
        return 'https:$imageUrl';
      }
      // 스키마가 없는 경우 https://를 앞에 붙임
      return 'https://$imageUrl';
    }
    return imageUrl;
  }

  Widget _buildReviewDetail(Review review) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              // 상단 앱바
              Container(
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        review.mallName ?? '리뷰',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 현재 페이지 표시
                    Text(
                      '${_currentReviewPage + 1} / ${_reviews.length}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.productName != null)
                GestureDetector(
                  onTap: () async {
                    if (review.productLink != null) {
                      final uri = Uri.tryParse(review.productLink!);
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
                      color: Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: review.productImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _getProductImageUrl(review.productImageUrl!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.productName!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (review.productPrice != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '₩${review.productPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              // 이미지 영역
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // 가로 스와이프 제스처는 이미지 영역에서만 처리
                    // 리뷰 간 이동은 세로 스와이프로만 처리
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: PageController(), // 각 이미지마다 독립적인 PageController
                          itemCount: review.imageUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: review.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 리뷰 내용
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (review.selectedOptions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: review.selectedOptions
                            .map((option) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    if (review.content != null &&
                        review.content!.isNotEmpty) ...[
                      if (review.selectedOptions.isNotEmpty)
                        const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          review.content!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // 세로 스크롤 힌트 (첫 번째 리뷰에서만 표시)
          if (_currentReviewPage == 0)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '위로 스와이프하여 다음 리뷰 보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _reviewPageController,
        scrollDirection: Axis.vertical, // 세로 스크롤로 변경
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _buildReviewDetail(review);
        },
      ),
    );
  }
} 