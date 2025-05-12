// ✅ 2. 패션 탭 - 에이블리 스타일 좋아요 리스트
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../call/presentation/product_webview_screen.dart';
import '../../data/like_repository.dart';
import '../../model/liked_product.dart';
import 'like_product_card.dart';

enum SortOption { priceHigh, priceLow }

class FashionLikedTab extends StatefulWidget {
  const FashionLikedTab({super.key});

  @override
  State<FashionLikedTab> createState() => _FashionLikedTabState();
}

class _FashionLikedTabState extends State<FashionLikedTab> {
  final likeRepo = LikeRepository();
  final formatter = NumberFormat('#,###', 'ko_KR');
  final ScrollController _scrollController = ScrollController();

  List<LikedProduct> _likes = [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 1;
  SortOption _selectedSort = SortOption.priceLow;

  @override
  void initState() {
    super.initState();
    _setupScroll();
    _loadInitial();
  }

  void _setupScroll() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _totalPages - 1) {
        _loadMore();
      }
    });
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });
    try {
      final pageData = await likeRepo.fetchLikedProducts(page: 0);
      setState(() {
        _likes = pageData.content;
        _currentPage = pageData.page;
        _totalPages = pageData.totalPages;
      });
      _applySort();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _totalPages - 1) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final pageData = await likeRepo.fetchLikedProducts(page: nextPage);
      setState(() {
        _likes.addAll(pageData.content);
        _currentPage = pageData.page;
        _totalPages = pageData.totalPages;
      });
      _applySort();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('추가 로딩 실패: $e')));
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _applySort() {
    setState(() {
      switch (_selectedSort) {
        case SortOption.priceHigh:
          _likes.sort((a, b) => b.productPrice.compareTo(a.productPrice));
          break;
        case SortOption.priceLow:
          _likes.sort((a, b) => a.productPrice.compareTo(b.productPrice));
          break;
      }
    });
  }

  Future<void> _removeLike(LikedProduct p) async {
    try {
      await likeRepo.deleteLike(
        historyCreatedAt: int.parse(p.historyAddedAt),
        recommendationId: p.recommendId,
        productId: p.productId,
        mallName: p.mallName,
      );
      setState(() {
        _likes.remove(p); // ✅ 삭제 후 즉시 UI 반영
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 삭제 실패: $e')),
      );
    }
  }

  void _onSortSelected(SortOption option) {
    _selectedSort = option;
    _applySort();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('에러 발생: $_error', style: TextStyle(color: Colors.white)),
      );
    }
    if (_likes.isEmpty) {
      return const Center(
        child: Text(
          '찜한 상품이 없습니다.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<SortOption>(
                icon: Icon(Icons.sort, color: Colors.white),
                onSelected: _onSortSelected,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SortOption.priceHigh,
                    child: Text('가격 높은순'),
                  ),
                  PopupMenuItem(
                    value: SortOption.priceLow,
                    child: Text('가격 낮은순'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: _likes.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _likes.length) {
                  final product = _likes[index];
                  return LikedProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductWebViewScreen(
                          url: product.productLink,
                        ),
                      ),
                    ),
                    onUnLike: () => _removeLike(product),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}