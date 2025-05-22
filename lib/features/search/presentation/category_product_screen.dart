// lib/features/search/presentation/widget/category_product_screen.dart

import 'package:alfred_clean/features/search/presentation/widget/sort_dropdown.dart';
import 'package:flutter/material.dart';
import '../data/search_repository.dart';
import '../../search/model/product.dart';
import '../presentation/widget/product_card.dart';

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

  bool _isSearching = false;
  late final TextEditingController _searchController;
  String? _searchKeyword;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchProducts();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      _hasMore   = response.nextCursor != null;
      _isLoading = false;
    });
  }

  void _onSortChanged(String sortBy, String sortDir) {
    setState(() {
      _sortBy = sortBy;
      _sortDir = sortDir;
    });

    // ① 스크롤을 맨 위로 올려서 사용자 경험 개선
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // ② API 를 새로 호출 (페이징 커서도 깨끗이 초기화)
    _fetchProducts(refresh: true);
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      if (_searchKeyword != null) {
        _searchKeyword = null;
        _fetchProducts(refresh: true);
      }
    });
  }

  void _onSearchSubmitted(String keyword) {
    final kw = keyword.trim();
    if (kw.isEmpty) return;

    setState(() {
      _isSearching = false;
      _searchKeyword = kw;
      _products.clear();
      _cursor = null;
      _hasMore = true;
    });
    _fetchProducts();
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
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearchSubmitted,
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
          ),
        )
            : Text(
          widget.category,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          _isSearching
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _cancelSearch,
          )
              : IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _startSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          SortDropdown(onChanged: _onSortChanged),
          if (_totalCount != null)               // ← count 가 있으면
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_totalCount개의 검색결과',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: _products[index]),
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
