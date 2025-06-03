// lib/features/search/presentation/widget/category_product_screen.dart
import 'package:alfred_clean/features/search/presentation/search_screen.dart';
import 'package:alfred_clean/common/widget/ad_banner_widget.dart'; // AdBannerWidget import 추가
import 'package:alfred_clean/features/search/presentation/widget/sort_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../call/model/product.dart';
import '../data/search_repository.dart';
import '../presentation/widget/product_card.dart';
import 'review_list_screen.dart';

class CategoryProductScreen extends StatefulWidget {
  final String category;

  const CategoryProductScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  final _repo = SearchRepository();
  final _scrollController = ScrollController();
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
      final response = await _repo.fetchProductsByCategory(
        category: widget.category,
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
      debugPrint('상품 조회 중 에러: ${e.message}');
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
      MaterialPageRoute(builder: (_) => const SearchScreen()),
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
        title: Text(
          widget.category,
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
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewListScreen(
                            category: widget.category,
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
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final productIndex = i + index;
                          if (productIndex >= _products.length || productIndex >= i + 10) return null;
                          return ProductCard(product: _products[productIndex]);
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
