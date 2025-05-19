// ✨ 기능은 그대로, 에러 방지 및 UI 안정화 수정 반영

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
    // 초기 liked 상태 로드
    for (final p in widget.history.recommendations) {
      if (p.liked) likedProductIds.add(p.productId);
    }
    _loadToken();
    // Mall별로 추천 상품 그룹핑
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
        // 상세에서 돌아갈 때 수정된 history를 반환
        Navigator.pop(context, widget.history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0.5,
          title: const Text(
            '추천 히스토리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, widget.history),
          ),
        ),
        body: groupedRecommendations.isEmpty
            ? const Center(child: Text('추천 결과가 없습니다.', style: TextStyle(color: Colors.white)))
            : ListView(
          children: groupedRecommendations.entries.map((entry) {
            final mall = entry.key;
            final products = entry.value;

            if (products.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          '💡 $mall',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(
                            color: Colors.white24,
                            thickness: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.92),
                      itemCount: products.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isLiked = likedProductIds.contains(product.productId);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: SizedBox(
                            height: 350,
                            child: ProductCard(
                              product: product,
                              isLiked: isLiked,
                              onLikeToggle: () => _toggleLike(product), historyCreatedAt: widget.history.createdAt,
                            ),
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
        // 로컬 liked 상태 토글
        if (wasLiked) {
          likedProductIds.remove(product.productId);
        } else {
          likedProductIds.add(product.productId);
        }
        // history 모델에도 반영
        final histList = widget.history.recommendations;
        final idx = histList.indexWhere((p) => p.productId == product.productId);
        if (idx != -1) {
          histList[idx] = histList[idx].copyWith(liked: !wasLiked);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 실패: $e')),
      );
    }
  }
}
