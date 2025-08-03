import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:alfred_clean/common/widget/ad_banner_widget.dart';
import '../data/search_repository.dart';
import '../model/care_review.dart';
import 'care_review_detail_screen.dart';
import 'care_review_search_screen.dart';

class CareKeywordReviewListScreen extends StatefulWidget {
  final String keyword;

  const CareKeywordReviewListScreen({
    super.key,
    required this.keyword,
  });

  @override
  State<CareKeywordReviewListScreen> createState() => _CareKeywordReviewListScreenState();
}

class _CareKeywordReviewListScreenState extends State<CareKeywordReviewListScreen> {
  final _repo = SearchRepository();
  final _scrollController = ScrollController();
  int? _totalCount;

  final List<CareReview> _reviews = [];
  String? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _searchKeyword;

  // 리뷰를 2개씩 묶어 한 행에 배치
  static const int _reviewsPerRow = 2;
  // 20개 리뷰마다 배너 삽입
  static const int _reviewsPerBanner = 20;
  // 한 블록 = 리뷰 10행 + 1배너
  static const int _blockRows = 11;

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
      final response = await _repo.fetchCareReviews(
        keyword: widget.keyword,
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
      debugPrint('뷰티케어 리뷰 조회 중 에러: ${e.message}');
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
      MaterialPageRoute(builder: (_) => const CareReviewSearchScreen()),
    );
    if (kw != null && kw.isNotEmpty) {
      setState(() {
        _searchKeyword = kw;
      });
      _fetchReviews(refresh: true);
    }
  }

  /// "리뷰를 2개씩 묶어 한 행에 배치" → 실제 리뷰 행(row) 개수
  int get _totalReviewRows {
    return (_reviews.length / _reviewsPerRow).ceil();
  }

  /// 전체 ListView에 필요한 슬롯(행) 개수 = 리뷰 행 + (리뷰 개수 ~/ 20)만큼의 배너 행
  int get _totalListItemCount {
    final bannerCount = _reviews.length ~/ _reviewsPerBanner;
    return _totalReviewRows + bannerCount;
  }

  /// 주어진 ListView 인덱스(idx)가 "배너 행"인지 판단
  bool _isBannerRow(int rowIdx) {
    // 한 블록(리뷰 10행 + 1배너)씩 보면,
    // (rowIdx + 1) % _blockRows == 0  이면 배너
    return ((rowIdx + 1) % _blockRows) == 0;
  }

  /// 주어진 ListView 인덱스(rowIdx)에 대응하는 "리뷰 행" 인덱스로 변환
  /// (즉, 배너 행들을 제외한 뒤 실제로 몇 번째 리뷰 행인지)
  int _reviewRowIndexForRow(int rowIdx) {
    // rowIdx까지 포함했을 때 들어간 "배너 행" 개수
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
          widget.keyword,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '$_totalCount개의 리뷰',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _reviews.isEmpty
                ? const Center(
                    child: Text(
                      '리뷰가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _totalListItemCount + (_isLoading ? 1 : 0),
                    itemBuilder: (context, rowIdx) {
                      if (rowIdx == _totalListItemCount) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (_isBannerRow(rowIdx)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child: const AdBannerWidget(),
                          ),
                        );
                      }

                      final reviewRowIdx = _reviewRowIndexForRow(rowIdx);
                      final startIndex = reviewRowIdx * _reviewsPerRow;
                      final endIndex = (startIndex + _reviewsPerRow).clamp(0, _reviews.length);
                      final rowReviews = _reviews.sublist(startIndex, endIndex);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            for (int i = 0; i < _reviewsPerRow; i++) ...[
                              if (i < rowReviews.length)
                                Expanded(
                                  child: _ReviewCard(review: rowReviews[i]),
                                )
                              else
                                const Expanded(child: SizedBox()),
                              if (i < _reviewsPerRow - 1) const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CareReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CareReviewDetailScreen(review: review),
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
                    review.mallName ?? '알 수 없음',
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

class _SwipeableImages extends StatefulWidget {
  final List<String> imageUrls;

  const _SwipeableImages({required this.imageUrls});

  @override
  State<_SwipeableImages> createState() => _SwipeableImagesState();
}

class _SwipeableImagesState extends State<_SwipeableImages> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
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