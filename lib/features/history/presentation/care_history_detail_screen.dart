import 'package:flutter/material.dart';
import 'package:alfred_clean/features/call/presentation/widget/care_product_card.dart';
import 'package:alfred_clean/features/call/presentation/product_webview_screen.dart';
import 'package:alfred_clean/features/history/model/care_history.dart';
import 'package:alfred_clean/features/history/presentation/widget/care_history_card.dart';
import 'package:alfred_clean/features/like/presentation/liked_product_screen.dart';
import 'package:alfred_clean/features/like/data/services/food_like_service.dart';
import 'package:alfred_clean/features/like/data/like_repository.dart';

class CareHistoryDetailScreen extends StatefulWidget {
  final CareHistory history;

  const CareHistoryDetailScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<CareHistoryDetailScreen> createState() => _CareHistoryDetailScreenState();
}

class _CareHistoryDetailScreenState extends State<CareHistoryDetailScreen> {
  late CareHistory _history;
  bool _isReasonExpanded = false; // 추천이유 섹션 접기/펼치기 상태
  final LikeRepository _likeRepository = LikeRepository();
  bool _isLikeLoading = false;
  String? _selectedMall; // 선택된 mallName 필터

  @override
  void initState() {
    super.initState();
    _history = widget.history;
  }

  // mallName 목록 가져오기
  List<String> get _mallNames {
    final Set<String> malls = {'전체'};
    for (var recommendation in _history.recommendations) {
      malls.add(recommendation.mallName);
    }
    return malls.toList();
  }

  // 필터링된 상품 목록
  List<CareRecommendation> get _filteredRecommendations {
    if (_selectedMall == null || _selectedMall == '전체') {
      return _history.recommendations;
    }
    return _history.recommendations.where((r) => r.mallName == _selectedMall).toList();
  }

  // 필터 섹션 제목 위젯
  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                '$title $count개',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // mallName 필터 버튼들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: _mallNames.map((mall) {
                final isSelected = _selectedMall == mall || (mall == '전체' && _selectedMall == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMall = mall == '전체' ? null : mall;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black87 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mall,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike(CareRecommendation recommendation) async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);

    try {
      if (recommendation.liked) {
        await _likeRepository.deleteLikeCare(
          historyId: _history.id,
          recommendationId: recommendation.id.toString(),
          productId: recommendation.productId,
          mallName: recommendation.mallName,
        );
      } else {
        await _likeRepository.postLikeCare(
          historyId: _history.id,
          recommendationId: recommendation.id.toString(),
          productId: recommendation.productId,
          mallName: recommendation.mallName,
        );
      }

      setState(() {
        _history = _history.copyWith(
          recommendations: _history.recommendations.map((r) {
            if (r.id == recommendation.id) {
              return CareRecommendation(
                id: r.id,
                productId: r.productId,
                productName: r.productName,
                productPrice: r.productPrice,
                productLink: r.productLink,
                productImage: r.productImage,
                productDescription: r.productDescription,
                source: r.source,
                mallName: r.mallName,
                keyword: r.keyword,
                reviewCount: r.reviewCount,
                liked: !r.liked,
              );
            }
            return r;
          }).toList(),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      setState(() => _isLikeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            '뷰티케어 히스토리',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context, _history),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LikedProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 히스토리 카드
              CareHistoryCard(
                history: _history,
                onTap: () {}, // 상세 화면에서는 탭 비활성화
              ),
              const SizedBox(height: 16),
              
              // 추천이유 섹션 (reason이 있을 때만 표시)
              if (_history.reason != null && _history.reason!.isNotEmpty) ...[
                _buildReasonSection(),
                const SizedBox(height: 16),
              ],
              
              // 상품 목록 섹션
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      title: '추천 상품',
                      icon: Icons.shopping_cart_outlined,
                      count: _filteredRecommendations.length,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 290,
                        ),
                        itemCount: _filteredRecommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = _filteredRecommendations[index];
                          final product = recommendation.toProduct();
                          
                          return CareProductCard(
                            product: product,
                            id: _history.id,
                            historyCreatedAt: _history.createdAt,
                            isLiked: recommendation.liked,
                            onLikeToggle: () => _handleLike(recommendation),
                            token: 'token', // 좋아요 버튼을 표시하기 위한 토큰
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20), // 하단 여백 추가
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF7B1FA2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '알프레드의 추천이유',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            initiallyExpanded: _isReasonExpanded,
            onExpansionChanged: (value) {
              setState(() {
                _isReasonExpanded = value;
              });
            },
            tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE1BEE7),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _history.reason!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 