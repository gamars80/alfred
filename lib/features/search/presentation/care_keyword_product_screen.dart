import 'package:alfred_clean/common/widget/ad_banner_widget.dart';
import 'package:alfred_clean/features/search/presentation/widget/care_sort_dropdown.dart';
import 'package:alfred_clean/features/search/presentation/widget/care_product_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/search_repository.dart';
import '../model/care_product.dart';
import 'care_keyword_review_list_screen.dart';
import 'care_search_screen.dart';

class CareKeywordProductScreen extends StatefulWidget {
  final String keyword;

  const CareKeywordProductScreen({
    super.key,
    required this.keyword,
  });

  @override
  State<CareKeywordProductScreen> createState() => _CareKeywordProductScreenState();
}

class _CareKeywordProductScreenState extends State<CareKeywordProductScreen> {
  final _repo = SearchRepository();
  final _scrollController = ScrollController();
  int? _totalCount;

  final List<CareProduct> _products = [];
  String? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  String? _searchKeyword;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
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
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    setState(() => _isLoading = true);

    if (refresh) {
      _products.clear();
      _cursor = null;
      _hasMore = true;
      _totalCount = null;
    }

    try {
      final response = await _repo.fetchCareProductsByKeyword(
        keyword: widget.keyword.isNotEmpty ? widget.keyword : null,
        cursor: _cursor,
        sortBy: _sortBy,
        sortDir: _sortDir,
        searchKeyword: _searchKeyword,
      );

      setState(() {
        _totalCount = response.totalCount;
        _products.addAll(response.items);
        _cursor = response.nextCursor;
        _hasMore = response.nextCursor != null;
      });
    } on DioException catch (e) {
      debugPrint('뷰티케어 상품 조회 중 에러: ${e.message}');
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

  void _onSortChanged(String sortBy, String sortDir) {
    setState(() {
      _sortBy = sortBy;
      _sortDir = sortDir;
    });

    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _fetchProducts(refresh: true);
  }

  Future<void> _onSearchTap() async {
    final kw = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CareSearchScreen()),
    );
    if (kw != null && kw.isNotEmpty) {
      setState(() {
        _searchKeyword = kw;
      });
      _fetchProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.keyword,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              '관련 뷰티케어 상품',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _onSearchTap,
          ),
        ],
      ),
      body: Column(
        children: [
          CareSortDropdown(onChanged: _onSortChanged),
          if (_totalCount != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '$_totalCount개의 검색결과',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CareKeywordReviewListScreen(
                            keyword: widget.keyword,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.reviews, size: 18),
                    label: const Text('전체 리뷰'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      for (int i = 0; i < _products.length; i += 10) ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.60,
                              mainAxisExtent: 290,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final productIndex = i + index;
                                if (productIndex >= _products.length || productIndex >= i + 10) return null;
                                return CareProductCard(product: _products[productIndex]);
                              },
                              childCount: (_products.length - i) >= 10 ? 10 : (_products.length - i),
                            ),
                          ),
                        ),
                        if (i + 10 <= _products.length)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: const AdBannerWidget(),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 