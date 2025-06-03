import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import '../../../common/widget/ad_banner_widget.dart';
import '../data/search_repository.dart';
import '../model/review.dart';
import 'review_search_screen.dart';
import 'review_detail_screen.dart';

class ReviewListScreen extends StatefulWidget {
  final String? category;
  final String? source;

  const ReviewListScreen({
    super.key,
    this.category,
    this.source,
  }) : assert(category != null || source != null);

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

  /// “리뷰 20개마다 한 줄 전체 폭 배너”를 삽입하기 위한 상수
  static const int _reviewsPerBanner = 20; // 배너 삽입 기준(리뷰 개수)
  static const int _reviewsPerRow = 2;     // 한 행(가로)에 2개의 리뷰 카드

  /// 한 배너 블록 당 “리뷰가 차지하는 행 수” = 20 / 2 = 10
  static final int _rowsPerBanner = _reviewsPerBanner ~/ _reviewsPerRow;

  /// 하나의 블록(10 Row 리뷰 + 1 Row 배너) 당 총 행 수
  static final int _blockRows = _rowsPerBanner + 1;

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

  /// “리뷰를 2개씩 묶어 한 행에 배치” → 실제 리뷰 행(row) 개수
  int get _totalReviewRows {
    return (_reviews.length / _reviewsPerRow).ceil();
  }

  /// 전체 ListView에 필요한 슬롯(행) 개수 = 리뷰 행 + (리뷰 개수 ~/ 20)만큼의 배너 행
  int get _totalListItemCount {
    final bannerCount = _reviews.length ~/ _reviewsPerBanner;
    return _totalReviewRows + bannerCount;
  }

  /// 주어진 ListView 인덱스(idx)가 “배너 행”인지 판단
  bool _isBannerRow(int rowIdx) {
    // 한 블록(리뷰 10행 + 1배너)씩 보면,
    // (rowIdx + 1) % _blockRows == 0  이면 배너
    return ((rowIdx + 1) % _blockRows) == 0;
  }

  /// 주어진 ListView 인덱스(rowIdx)에 대응하는 “리뷰 행” 인덱스로 변환
  /// (즉, 배너 행들을 제외한 뒤 실제로 몇 번째 리뷰 행인지)
  int _reviewRowIndexForRow(int rowIdx) {
    // rowIdx까지 포함했을 때 들어간 “배너 행” 개수
    final bannersBefore = (rowIdx + 1) ~/ _blockRows;
    // 따라서 실제 리뷰 행 인덱스 = rowIdx - bannersBefore
    return rowIdx - bannersBefore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.category ?? widget.source!,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearchTap,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_totalCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$_totalCount개의 리뷰',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Stack(
              children: [
                // ────────────────────────────────────────────
                // ListView.builder + Row로 수동 2열 레이아웃 짜기
                // ────────────────────────────────────────────
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _totalListItemCount,
                  itemBuilder: (context, rowIdx) {
                    // 1) “배너 행”이면
                    if (_isBannerRow(rowIdx)) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: const AdBannerWidget(),
                        ),
                      );
                    }

                    // 2) 리뷰 행(row) 처리
                    // 실제 리뷰 행 인덱스 계산
                    final reviewRowIdx = _reviewRowIndexForRow(rowIdx);
                    // 한 행에 두 개의 리뷰 카드: leftReviewIdx = reviewRowIdx*2
                    final leftReviewIdx = reviewRowIdx * _reviewsPerRow;
                    final rightReviewIdx = leftReviewIdx + 1;

                    // 왼쪽 카드(반드시 있음)
                    final leftCard = _buildReviewCard(leftReviewIdx);

                    // 오른쪽 카드(만약 인덱스를 넘어가면 빈 박스로 대체)
                    Widget rightCard = const SizedBox.shrink();
                    if (rightReviewIdx < _reviews.length) {
                      rightCard = _buildReviewCard(rightReviewIdx);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          // 왼쪽 카드
                          Expanded(child: leftCard),
                          const SizedBox(width: 8),
                          // 오른쪽 카드
                          Expanded(child: rightCard),
                        ],
                      ),
                    );
                  },
                ),

                // ────────────────────────────────────────────
                // 로딩 인디케이터 (추가 로드용)
                // ────────────────────────────────────────────
                if (_isLoading)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black87),
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

  /// 주어진 “리뷰 인덱스”에 해당하는 카드 위젯
  Widget _buildReviewCard(int reviewIdx) {
    final review = _reviews[reviewIdx];
    return _ReviewCard(review: review);
  }
}

/// ───────────────────────────────────────────────────────
/// 리뷰 하나를 보여주는 카드 위젯
/// ───────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    if (review.imageUrls.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewDetailScreen(review: review),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.all(2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: review.imageUrls.length == 1
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: review.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey[200]),
                  ),
                )
                    : _SwipeableImages(imageUrls: review.imageUrls),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.mallName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (review.imageUrls.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swipe_left,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${review.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
  }
}

/// ───────────────────────────────────────────────────────
/// 여러 이미지를 좌우 스와이프하여 볼 수 있게 해주는 위젯
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
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[200]),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                    (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
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
    );
  }
}
