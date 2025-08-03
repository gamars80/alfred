import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../common/widget/ad_banner_widget.dart';
import '../data/search_repository.dart';
import '../model/review.dart';
import 'review_search_screen.dart';
import 'review_detail_screen.dart';

class PinterestReviewTheme {
  // 핀터레스트 스타일 색상 팔레트
  static const Color primaryColor = Color(0xFFE60023); // 핀터레스트 레드
  static const Color secondaryColor = Color(0xFF333333); // 다크 그레이
  static const Color backgroundColor = Color(0xFFF8F9FA); // 라이트 그레이
  static const Color cardBackground = Color(0xFFFFFFFF); // 화이트
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF666666);
  
  // 카드 스타일
  static const double cardRadius = 16.0;
  static const double cardElevation = 8.0;
  
  // 그림자 효과 (핀터레스트 스타일)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  // 호버 효과를 위한 그림자
  static const List<BoxShadow> cardHoverShadow = [
    BoxShadow(
      color: Color(0x2A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // 배지 스타일
  static const double badgeRadius = 20.0;
  static const Color badgeBackground = Color(0xCC000000);
  static const Color badgeTextColor = Color(0xFFFFFFFF);
}

class ReviewListScreen extends StatefulWidget {
  final String? category;
  final String? source;

  const ReviewListScreen({
    super.key,
    this.category,
    this.source,
  });

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final _repo = SearchRepository();
  final _scrollController = ScrollController();

  int? _totalCount;
  final List<Review> _reviews = [];
  String? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _searchKeyword;

  /// "리뷰 20개마다 한 줄 전체 폭 배너"를 삽입하기 위한 상수
  static const int _reviewsPerRow = 2;     // 한 행(가로)에 2개의 리뷰 카드

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews({bool refresh = false}) async {
    setState(() => _isLoading = true);

    if (refresh) {
      _reviews.clear();
      _cursor = null;
      _hasMore = true;
      _totalCount = null;
    }

    try {
      final response = await _repo.fetchReviews(
        category: widget.category,
        source: widget.source,
        cursor: _cursor,
        searchKeyword: _searchKeyword,
      );

      setState(() {
        _totalCount = response.totalCount;
        _reviews.addAll(response.items.reversed);
        _cursor = response.nextCursor;
        _hasMore = response.nextCursor != null;
      });
    } on DioException catch (e) {
      debugPrint('리뷰 조회 중 에러: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검색 중 서버 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSearchTap() async {
    final kw = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ReviewSearchScreen()),
    );
    if (kw != null && kw.isNotEmpty) {
      setState(() {
        _searchKeyword = kw;
      });
      _fetchReviews(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PinterestReviewTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: PinterestReviewTheme.cardBackground,
        surfaceTintColor: PinterestReviewTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: PinterestReviewTheme.textColor),
        title: Text(
          widget.category ?? widget.source ?? '전체 리뷰',
          style: const TextStyle(
            color: PinterestReviewTheme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: PinterestReviewTheme.textColor),
            onPressed: _onSearchTap,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_totalCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: PinterestReviewTheme.cardBackground,
                border: Border(
                  bottom: BorderSide(color: PinterestReviewTheme.backgroundColor),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$_totalCount개의 리뷰',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PinterestReviewTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Stack(
              children: [
                // ────────────────────────────────────────────
                // 진짜 핀터레스트 스타일 매슨리 레이아웃
                // ────────────────────────────────────────────
                MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return _buildPinterestCard(index);
                  },
                ),

                // ────────────────────────────────────────────
                // 로딩 인디케이터 (추가 로드용) - 핀터레스트 스타일
                // ────────────────────────────────────────────
                if (_isLoading)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PinterestReviewTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 진짜 핀터레스트 스타일 카드 (이미지만, 다양한 높이)
  Widget _buildPinterestCard(int reviewIndex) {
    final review = _reviews[reviewIndex];
    return _PinterestImageCard(
      review: review,
      index: reviewIndex,
      allReviews: _reviews,
    );
  }
}

/// ───────────────────────────────────────────────────────
/// 진짜 핀터레스트 스타일 이미지 카드 (이미지만, 다양한 높이)
/// ───────────────────────────────────────────────────────
class _PinterestImageCard extends StatefulWidget {
  final Review review;
  final int index;
  final List<Review> allReviews;

  const _PinterestImageCard({
    super.key,
    required this.review,
    required this.index,
    required this.allReviews,
  });

  @override
  State<_PinterestImageCard> createState() => _PinterestImageCardState();
}

class _PinterestImageCardState extends State<_PinterestImageCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// 이미지 비율에 따른 높이 계산 (핀터레스트 스타일)
  double _getImageHeight() {
    // 진짜 매슨리 레이아웃을 위한 극적인 높이 차이
    final random = (widget.review.hashCode % 6) + 1; // 1, 2, 3, 4, 5, 6 중 하나
    switch (random) {
      case 1:
        return 100; // 매우 짧은 이미지
      case 2:
        return 140; // 짧은 이미지
      case 3:
        return 180; // 중간 이미지
      case 4:
        return 220; // 긴 이미지
      case 5:
        return 260; // 매우 긴 이미지
      case 6:
        return 300; // 극도로 긴 이미지
      default:
        return 180;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.review.imageUrls.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: () {
                  debugPrint('PinterestImageCard - 이미지 클릭: ${widget.review.id}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewDetailScreen(
                        review: widget.review,
                        allReviews: widget.allReviews, // 모든 리뷰 전달
                        initialIndex: widget.index, // 현재 인덱스 전달
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: PinterestReviewTheme.cardBackground,
                    borderRadius: BorderRadius.circular(PinterestReviewTheme.cardRadius),
                    boxShadow: _isHovered 
                        ? PinterestReviewTheme.cardHoverShadow 
                        : PinterestReviewTheme.cardShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // 이미지 영역 (다양한 높이)
                      Container(
                        height: _getImageHeight(),
                        width: double.infinity,
                        child: widget.review.imageUrls.length == 1
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(PinterestReviewTheme.cardRadius),
                          child: CachedNetworkImage(
                            imageUrl: widget.review.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(
                                  color: PinterestReviewTheme.backgroundColor,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        PinterestReviewTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Container(
                                  color: PinterestReviewTheme.backgroundColor,
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: PinterestReviewTheme.subtitleColor,
                                    size: 48,
                                  ),
                                ),
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(PinterestReviewTheme.cardRadius),
                          child: _SwipeableImages(imageUrls: widget.review.imageUrls),
                        ),
                      ),
                      // 쇼핑몰 배지
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: PinterestReviewTheme.badgeBackground.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.review.mallName ?? '',
                            style: const TextStyle(
                              color: PinterestReviewTheme.badgeTextColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // 이미지 개수 표시
                      if (widget.review.imageUrls.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: PinterestReviewTheme.badgeBackground.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_rounded,
                                  color: PinterestReviewTheme.badgeTextColor,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.review.imageUrls.length}',
                                  style: const TextStyle(
                                    color: PinterestReviewTheme.badgeTextColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ),
    );
  }
}

/// ───────────────────────────────────────────────────────
/// 여러 이미지를 좌우 스와이프하여 볼 수 있게 해주는 위젯 (핀터레스트 스타일)
/// ───────────────────────────────────────────────────────
class _SwipeableImages extends StatefulWidget {
  final List<String> imageUrls;

  const _SwipeableImages({required this.imageUrls});

  @override
  State<_SwipeableImages> createState() => _SwipeableImagesState();
}

class _SwipeableImagesState extends State<_SwipeableImages> {
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
    return Container(
      height: double.infinity, // 부모 높이에 맞춤
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(PinterestReviewTheme.cardRadius),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(
                        color: PinterestReviewTheme.backgroundColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PinterestReviewTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) =>
                      Container(
                        color: PinterestReviewTheme.backgroundColor,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: PinterestReviewTheme.subtitleColor,
                          size: 48,
                        ),
                      ),
                ),
              );
            },
          ),
          // 페이지 인디케이터
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                    (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? PinterestReviewTheme.primaryColor
                        : PinterestReviewTheme.primaryColor.withOpacity(0.3),
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
