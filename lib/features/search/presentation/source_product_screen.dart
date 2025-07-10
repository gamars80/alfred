// lib/features/search/presentation/source_product_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../common/widget/ad_banner_widget.dart';
import '../../call/model/product.dart';
import '../data/search_repository.dart';
import '../presentation/widget/product_card.dart';
import 'review_list_screen.dart';
import 'search_screen.dart';
import 'widget/sort_dropdown.dart';

class SourceProductScreen extends StatefulWidget {
  final String source;
  const SourceProductScreen({super.key, required this.source});

  @override
  State<SourceProductScreen> createState() => _SourceProductScreenState();
}

class _SourceProductScreenState extends State<SourceProductScreen> {
  final _repo = SearchRepository();
  final ScrollController _scrollController = ScrollController();
  int? _totalCount;

  final List<Product> _products = [];
  String? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  String? _searchKeyword;

  @override
  void initState() {
    debugPrint('SourceProductScreen - initState called with source: ${widget.source}');
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    debugPrint('SourceProductScreen - dispose called');
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    debugPrint('SourceProductScreen - onScroll called, position: ${_scrollController.position.pixels}, maxExtent: ${_scrollController.position.maxScrollExtent}');
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    debugPrint('SourceProductScreen - fetchProducts called, refresh: $refresh');

    if (_isLoading) return; // 이미 로딩 중이면 중복 요청 방지

    setState(() => _isLoading = true);

    if (refresh) {
      debugPrint('SourceProductScreen - Refreshing products - clearing existing data');
      _products.clear();
      _cursor = null;
      _hasMore = true;
      _totalCount = null;
    }

    try {
      debugPrint('SourceProductScreen - Fetching products from repository - source: ${widget.source}, cursor: $_cursor');
      final response = await _repo.fetchProductsBySource(
        source: widget.source,
        cursor: _cursor,
        sortBy: _sortBy,
        sortDir: _sortDir,
        searchKeyword: _searchKeyword,
      );

      if (!mounted) return;

      setState(() {
        _totalCount = response.totalCount;
        _products.addAll(response.items);
        _cursor = response.nextCursor;
        _hasMore = response.nextCursor != null;
        debugPrint('SourceProductScreen - State updated - total products: ${_products.length}, hasMore: $_hasMore');
      });
    } on DioException catch (e) {
      debugPrint('SourceProductScreen - Error fetching products: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.statusCode == 500
              ? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
              : '검색 중 오류가 발생했습니다.'),
          ),
        );
      }
      setState(() => _hasMore = false); // 에러 발생 시 더 이상 로드하지 않음
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (kw != null && kw.isNotEmpty) {
      setState(() => _searchKeyword = kw);
      _fetchProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SourceProductScreen - build called, products length: ${_products.length}');
    // 동적으로 카드 높이 계산: 카드 너비의 1.25배
    final double gridWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2; // 패딩, crossAxisSpacing 반영
    final double cardHeight = gridWidth * 1.85;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.source,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
          SortDropdown(onChanged: _onSortChanged),
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
                  if (widget.source != 'ABLY') // ABLY가 아닐 때만 전체 리뷰 버튼 표시
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReviewListScreen(source: widget.source),
                          ),
                        );
                      },
                      icon: const Icon(Icons.reviews, size: 18),
                      label: const Text('전체 리뷰'),
                      style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
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
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.60,
                            mainAxisExtent: cardHeight,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final productIndex = i + index;
                              if (productIndex >= _products.length || productIndex >= i + 10) return null;
                              return ProductCard(product: _products[productIndex], cardHeight: cardHeight);
                            },
                            childCount: 10,
                          ),
                        ),
                      ),
                      if (i + 10 <= _products.length) // 10개 단위로 광고 표시
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

  // 전체 아이템 개수 계산 (상품 + 광고)
  int _calculateTotalItems() {
    if (_products.isEmpty) return 0;

    // 10개마다 광고 1개 추가 (row 단위가 아닌 개별 상품 기준)
    final productRows = (_products.length / 2).ceil(); // 2개씩 표시하므로 row 수 계산
    final adCount = (_products.length - 1) ~/ 10; // 10개 단위로 광고 추가
    final totalCount = productRows + adCount;

    debugPrint('SourceProductScreen - Calculating total items: products=${_products.length}, rows=$productRows, ads=$adCount, total=$totalCount');
    return totalCount;
  }

  // 2개의 상품을 포함하는 row 위젯 생성
  Widget _buildProductRow(int leftIndex, int? rightIndex, double cardHeight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ProductCard(product: _products[leftIndex], cardHeight: cardHeight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: rightIndex != null && rightIndex < _products.length
                ? ProductCard(product: _products[rightIndex], cardHeight: cardHeight)
                : const SizedBox(), // 오른쪽 상품이 없을 경우 빈 공간
          ),
        ],
      ),
    );
  }
}
