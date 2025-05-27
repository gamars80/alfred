// lib/features/history/presentation/history_detail_screen.dart
import 'package:alfred_clean/features/call/model/product.dart';
import 'package:flutter/material.dart';

import '../../../service/token_manager.dart';
import '../../call/presentation/widget/product_card.dart';
import '../../like/data/like_repository.dart';
import '../data/history_repository.dart';
import '../model/recommendation_history.dart';

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
  String? selectedMall;  // 선택된 쇼핑몰

  late final Map<String, List<Product>> groupedRecommendations;
  late final List<String> mallList;  // 쇼핑몰 리스트

  @override
  void initState() {
    super.initState();
    for (final p in widget.history.recommendations) {
      if (p.liked) likedProductIds.add(p.productId);
    }
    _loadToken();

    groupedRecommendations = {};
    for (final p in widget.history.recommendations) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    debugPrint('Screen size: ${screenWidth}x${screenHeight}');
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            '추천 히스토리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context, widget.history),
          ),
        ),
        body: groupedRecommendations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      '추천 결과가 없습니다.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
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
                            onSelected: (_) {
                              setState(() {
                                selectedMall = isAll ? null : mallName;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF7B61FF),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
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
                      children: (selectedMall == null
                              ? groupedRecommendations.entries.toList()
                              : groupedRecommendations.entries
                                  .where((e) => e.key == selectedMall)
                                  .toList())
                          .map((entry) {
                        final mall = entry.key;
                        final products = entry.value;
                        if (products.isEmpty) return const SizedBox.shrink();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF7B61FF).withOpacity(0.1),
                                                const Color(0xFF5B4CFF).withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.storefront_rounded,
                                            size: 18,
                                            color: Color(0xFF7B61FF),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          mall,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF212121),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${products.length}개',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'AI가 추천한 ${mall}의 인기 상품',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: () {
                                    // 안전 마진을 포함한 더 보수적인 계산
                                    if (screenWidth <= 320) return 0.52;      // 0.40 → 0.52
                                    if (screenWidth <= 360) return 0.54;      // 0.41 → 0.54
                                    if (screenWidth <= 375) return 0.56;      // 0.42 → 0.56
                                    if (screenWidth <= 390) return 0.58;      // 0.43 → 0.58
                                    if (screenWidth <= 414) return 0.60;      // 0.44 → 0.60
                                    if (screenWidth <= 428) return 0.62;      // 0.45 → 0.62
                                    return 0.64;                              // 0.46 → 0.64
                                  }(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final isLiked =
                                      likedProductIds.contains(product.productId);

                                  return ProductCard(
                                    product: product,
                                    isLiked: isLiked,
                                    onLikeToggle: () => _toggleLike(product),
                                    historyCreatedAt: widget.history.createdAt,
                                    token: token,
                                  );
                                },
                              ),
                              if (selectedMall == null && 
                                  entry != groupedRecommendations.entries.last)
                                Container(
                                  margin: const EdgeInsets.only(top: 24),
                                  height: 8,
                                  color: const Color(0xFFF5F5F5),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
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
          historyCreatedAt: widget.history.createdAt,
          recommendationId: product.recommendationId,
          productId: product.productId,
          mallName: product.mallName,
        );
      } else {
        await likeRepo.postLike(
          historyCreatedAt: widget.history.createdAt,
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
        final idx = widget.history.recommendations
            .indexWhere((p) => p.productId == product.productId);
        if (idx != -1) {
          widget.history.recommendations[idx] =
              widget.history.recommendations[idx].copyWith(liked: !wasLiked);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패: \$e')));
    }
  }
}
