import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/like_repository.dart';
import '../../model/liked_care_product.dart';
import 'like_care_product_card.dart';

class CareLikedTab extends StatefulWidget {
  const CareLikedTab({super.key});

  @override
  State<CareLikedTab> createState() => _CareLikedTabState();
}

class _CareLikedTabState extends State<CareLikedTab> {
  final ScrollController _scrollController = ScrollController();
  final _likeRepository = LikeRepository();
  final List<LikedCareProduct> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _likeRepository.fetchLikedCare(page: _currentPage);
      
      setState(() {
        _products.addAll(result.content);
        _currentPage++;
        _hasMore = _currentPage < result.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '데이터를 불러오는데 실패했습니다.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error ?? '알 수 없는 오류가 발생했습니다')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadProducts();
    }
  }

  Future<void> _deleteLike(LikedCareProduct product) async {
    try {
      await _likeRepository.deleteLikeCare(
        historyId: product.historyId,
        recommendationId: product.recommendId,
        productId: product.productId,
        mallName: product.mallName,
      );
      
      setState(() {
        _products.remove(product);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜 목록에서 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜 삭제에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentPage = 0;
                  _products.clear();
                  _hasMore = true;
                });
                _loadProducts();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text(
          '찜한 뷰티케어 상품이 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 300,
      ),
      itemCount: _products.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _products.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = _products[index];
        return LikeCareProductCard(
          product: product,
          onUnlike: () => _deleteLike(product),
        );
      },
    );
  }
} 