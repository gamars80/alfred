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

  late final Map<String, List<Product>> groupedRecommendations;

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
  }

  Future<void> _loadToken() async {
    final t = await TokenManager.getToken();
    setState(() {
      token = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '추천 히스토리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context, widget.history),
          ),
        ),
        body: groupedRecommendations.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 48, color: Colors.white38),
                    SizedBox(height: 16),
                    Text(
                      '추천 결과가 없습니다.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                physics: const BouncingScrollPhysics(),
                children: groupedRecommendations.entries.map((entry) {
                  final mall = entry.key;
                  final products = entry.value;
                  if (products.isEmpty) return const SizedBox.shrink();

                  final availableWidth = MediaQuery.of(context).size.width;
                  final cardWidth = availableWidth * 0.92 - 16;
                  const textAreaHeight = 160.0;
                  final pageHeight = cardWidth + textAreaHeight;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.withOpacity(0.6),
                                      Colors.blue.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      mall,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white24,
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: pageHeight,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.92),
                            itemCount: products.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final isLiked = likedProductIds.contains(product.productId);

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ProductCard(
                                  product: product,
                                  isLiked: isLiked,
                                  onLikeToggle: () => _toggleLike(product),
                                  historyCreatedAt: widget.history.createdAt,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
