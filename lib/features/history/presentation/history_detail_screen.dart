// lib/features/history/presentation/history_detail_screen.dart
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:flutter/material.dart';

import '../../../service/token_manager.dart';
import '../../call/presentation/widget/product_card.dart';
import '../../like/data/like_repository.dart';
import '../data/history_repository.dart';
import '../model/recommendation_history.dart';
import 'package:alfred_clean/common/widget/ad_banner_widget.dart';

class HistoryDetailScreen extends StatefulWidget {
  final RecommendationHistory history;
  const HistoryDetailScreen({super.key, required this.history});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final repo = HistoryRepository();
  final likeRepo = LikeRepository();
  final Set<String> likedProductIds = {};
  String? token;
  String? selectedMall;
  int _selectedRating = 0;
  bool _isRatingLoading = false;
  late RecommendationHistory _history;

  late final Map<String, List<Product>> groupedRecommendations;
  late final List<String> mallList;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
    for (final p in _history.recommendations) {
      if (p.liked) likedProductIds.add(p.productId);
    }
    _loadToken();

    groupedRecommendations = {};
    for (final p in _history.recommendations) {
      groupedRecommendations.putIfAbsent(p.mallName, () => []).add(p);
    }
    mallList = groupedRecommendations.keys.toList();
  }

  Future<void> _loadToken() async {
    final t = await TokenManager.getToken();
    setState(() {
      token = t;
    });
  }

  Future<void> _submitRating(int rating) async {
    if (_isRatingLoading) return;
    setState(() => _isRatingLoading = true);
    try {
      await repo.postRating(
        historyId: _history.id,
        rating: rating,
      );
      setState(() {
        _history = _history.copyWith(
          hasRating: true,
          myRating: rating,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('평가가 완료되었습니다.'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('평가 저장 중 오류가 발생했습니다: \$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isRatingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('추천 히스토리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: -0.5)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context, _history),
          ),
        ),
        body: Stack(
          children: [
            groupedRecommendations.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]), const SizedBox(height: 16), Text('추천 결과가 없습니다.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500))]))
                : Column(
              children: [
                Container(
                  height: 44,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mallList.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final mallName = isAll ? "전체" : mallList[index - 1];
                      final isSelected = isAll ? selectedMall == null : selectedMall == mallName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(mallName),
                          selected: isSelected,
                          onSelected: (_) => setState(() => selectedMall = isAll ? null : mallName),
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF7B61FF),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[700]),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!, width: 1)),
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 0,
                          shadowColor: const Color(0xFF7B61FF).withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: AdBannerWidget())),
                      ...(
                          selectedMall == null
                              ? groupedRecommendations.entries.toList()
                              : groupedRecommendations.entries.where((e) => e.key == selectedMall).toList()
                      ).expand((entry) {
                        final mall = entry.key;
                        final products = entry.value;
                        if (products.isEmpty) return [];
                        return [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [const Color(0xFF7B61FF).withOpacity(0.1), const Color(0xFF5B4CFF).withOpacity(0.1)]),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFF7B61FF)),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(mall, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212121), letterSpacing: -0.5)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                                          child: Text('${products.length}개', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF757575))),
                                        )
                                      ]),
                                      const SizedBox(height: 4),
                                      Text('AI가 추천한 $mall의 인기 상품', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: () {
                                      if (screenWidth <= 320) return 0.52;
                                      if (screenWidth <= 360) return 0.54;
                                      if (screenWidth <= 375) return 0.56;
                                      if (screenWidth <= 390) return 0.58;
                                      if (screenWidth <= 414) return 0.60;
                                      if (screenWidth <= 428) return 0.62;
                                      return 0.64;
                                    }(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    final isLiked = likedProductIds.contains(product.productId);
                                    return ProductCard(
                                      id: _history.id,
                                      product: product,
                                      isLiked: isLiked,
                                      onLikeToggle: () => _toggleLike(product),
                                      historyCreatedAt: _history.createdAt,
                                      token: token,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: AdBannerWidget())),
                        ];
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
            if (!_history.hasRating)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -4))],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                      const Text("주인님 저희 추천에 평가를 내려주세요", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: _isRatingLoading ? null : () async {
                              final newRating = index + 1;
                              setState(() => _selectedRating = newRating);
                              await _submitRating(newRating);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(index < _selectedRating ? Icons.star : Icons.star_border, size: 40, color: _isRatingLoading ? Colors.grey : Colors.amber),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      if (_isRatingLoading) const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike(Product product) async {
    if (token == null) return;
    final wasLiked = likedProductIds.contains(product.productId);
    try {
      if (wasLiked) {
        await likeRepo.deleteLike(
          historyId: _history.id,
          recommendationId: product.recommendationId,
          productId: product.productId,
          mallName: product.mallName,
        );
      } else {
        await likeRepo.postLike(
          historyId: _history.id,
          recommendationId: product.recommendationId,
          productId: product.productId,
          mallName: product.mallName,
        );
      }
      setState(() {
        if (wasLiked) {
          likedProductIds.remove(product.productId);
        } else {
          likedProductIds.add(product.productId);
        }
        final idx = _history.recommendations.indexWhere((p) => p.productId == product.productId);
        if (idx != -1) {
          _history.recommendations[idx] = _history.recommendations[idx].copyWith(liked: !wasLiked);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패: \$e')));
    }
  }
}
