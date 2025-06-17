import 'package:alfred_clean/features/auth/common/dio/dio_client.dart';
import 'package:alfred_clean/features/like/data/like_repository.dart';
import 'package:alfred_clean/features/like/data/services/food_like_service.dart';
import 'package:alfred_clean/features/like/domain/models/food_like_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodLikedTab extends StatefulWidget {
  const FoodLikedTab({super.key});

  @override
  State<FoodLikedTab> createState() => _FoodLikedTabState();
}

class _FoodLikedTabState extends State<FoodLikedTab> {
  final ScrollController _scrollController = ScrollController();
  late final FoodLikeService _service;
  final _likeRepository = LikeRepository();
  final List<FoodLikeModel> _foods = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadFoods();
    _scrollController.addListener(_onScroll);
  }

  void _initializeService() {
    _service = FoodLikeService(DioClient.dio);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getLikedFoods(page: _currentPage);
      final foods = result['content'] as List<FoodLikeModel>;
      
      setState(() {
        _foods.addAll(foods);
        _currentPage++;
        _hasMore = _currentPage < result['totalPages'];
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
      _loadFoods();
    }
  }

  Future<void> _deleteLike(FoodLikeModel food) async {
    try {
      await _likeRepository.deleteLikeFood(
        historyId: food.historyId,
        recommendationId: food.recommendId,
        productId: food.productId,
        mallName: food.mallName,
      );
      
      setState(() {
        _foods.remove(food);
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
    if (_error != null && _foods.isEmpty) {
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
                  _foods.clear();
                  _hasMore = true;
                });
                _loadFoods();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_foods.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      itemCount: _foods.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _foods.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final food = _foods[index];
        return _FoodCard(
          food: food,
          onDelete: () => _deleteLike(food),
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodLikeModel food;
  final VoidCallback onDelete;

  const _FoodCard({
    required this.food,
    required this.onDelete,
  });

  Future<void> _launchProductUrl(BuildContext context) async {
    final uri = Uri.parse(food.productLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품 링크를 열 수 없습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchProductUrl(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _launchProductUrl(context),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        food.productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error_outline),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      food.mallName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                food.productName,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (food.productDescription.isNotEmpty) ...[
                            Expanded(
                              flex: 3,
                              child: Text(
                                food.productDescription,
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      NumberFormat.currency(
                        locale: 'ko_KR',
                        symbol: '₩',
                        decimalDigits: 0,
                      ).format(food.productPrice),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 