// ✅ 2. 패션 탭 - 에이블리 스타일 좋아요 리스트
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
        historyId: p.historyId,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '정렬',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<SortOption>(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[700],
                  size: 20,
                ),
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: _onSortSelected,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortOption.priceHigh,
                    child: Row(
                      children: [
                        Text(
                          '가격 높은순',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: _selectedSort == SortOption.priceHigh
                                ? const Color(0xFF1A1A1A)
                                : Colors.grey[600],
                            fontWeight: _selectedSort == SortOption.priceHigh
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (_selectedSort == SortOption.priceHigh)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortOption.priceLow,
                    child: Row(
                      children: [
                        Text(
                          '가격 낮은순',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: _selectedSort == SortOption.priceLow
                                ? const Color(0xFF1A1A1A)
                                : Colors.grey[600],
                            fontWeight: _selectedSort == SortOption.priceLow
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (_selectedSort == SortOption.priceLow)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.5,
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
                        productId: product.productId,
                        historyId: product.historyId,
                        source: product.source,
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
      ],
    );
  }
}