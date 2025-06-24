import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../common/widget/ad_banner_widget.dart';
import '../../call/model/product.dart';
import '../data/search_repository.dart';
import '../presentation/widget/product_card.dart';
import 'search_screen.dart';
import 'widget/sort_dropdown.dart';

class AllFashionProductScreen extends StatefulWidget {
  const AllFashionProductScreen({super.key});

  @override
  State<AllFashionProductScreen> createState() => _AllFashionProductScreenState();
}

class _AllFashionProductScreenState extends State<AllFashionProductScreen> {
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
    debugPrint('AllFashionProductScreen - initState called');
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    debugPrint('AllFashionProductScreen - dispose called');
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    debugPrint('AllFashionProductScreen - onScroll called, position: ${_scrollController.position.pixels}, maxExtent: ${_scrollController.position.maxScrollExtent}');
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    debugPrint('AllFashionProductScreen - fetchProducts called, refresh: $refresh');
    
    if (_isLoading) return; // 이미 로딩 중이면 중복 요청 방지
    
    setState(() => _isLoading = true);

    if (refresh) {
      debugPrint('AllFashionProductScreen - Refreshing products - clearing existing data');
      _products.clear();
      _cursor = null;
      _hasMore = true;
      _totalCount = null;
    }

    try {
      debugPrint('AllFashionProductScreen - Fetching all products from repository - cursor: $_cursor');
      final response = await _repo.fetchAllProducts(
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
        debugPrint('AllFashionProductScreen - State updated - total products: ${_products.length}, hasMore: $_hasMore');
      });
    } on DioException catch (e) {
      debugPrint('AllFashionProductScreen - Error fetching products: ${e.message}');
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
    debugPrint('AllFashionProductScreen - build called, products length: ${_products.length}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '전체 패션 상품',
          style: TextStyle(
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.60,
                            mainAxisExtent: 280,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final productIndex = i + index;
                              if (productIndex >= _products.length || productIndex >= i + 10) return null;
                              return ProductCard(product: _products[productIndex]);
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
} 