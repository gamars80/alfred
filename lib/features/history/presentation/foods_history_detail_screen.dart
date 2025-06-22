import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/foods_history.dart';
import '../data/history_repository.dart';
import '../../like/data/like_repository.dart';
import '../../../../common/presentation/web_view_screen.dart';
import '../../../../features/call/data/food_api.dart';
import '../../review/presentation/food_review_overlay_screen.dart';
import '../../call/model/product.dart';

class FoodsHistoryDetailScreen extends StatefulWidget {
  final FoodsHistory history;

  const FoodsHistoryDetailScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<FoodsHistoryDetailScreen> createState() => _FoodsHistoryDetailScreenState();
}

class _ProductGridItem extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final int price;
  final String mallName;
  final int? reviewCount;
  final double? rating;
  final String? description;
  final String? productLink;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final String productId;
  final String source;
  final int historyId;

  const _ProductGridItem({
    super.key,
    this.imageUrl,
    required this.name,
    required this.price,
    required this.mallName,
    this.reviewCount,
    this.rating,
    this.description,
    this.productLink,
    this.isLiked = false,
    this.onLikeTap,
    required this.productId,
    required this.source,
    required this.historyId,
  });

  static final FoodApi _foodApi = FoodApi();

  Future<void> _launchUrl(BuildContext context) async {
    // openFood API 비동기 호출
    _foodApi.openFood(productId, historyId.toString(), source);
    if (productLink != null) {
      final Uri url = Uri.parse(productLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('링크를 열 수 없습니다.')),
          );
        }
      }
    }
  }

  void _openReviews(BuildContext context) {
    // FoodsProduct를 Product로 변환
    final product = Product(
      recommendationId: productId,
      productId: productId,
      name: name,
      price: price,
      image: imageUrl ?? '',
      link: productLink ?? '',
      mallName: mallName,
      source: source,
      reviewCount: reviewCount ?? 0,
      reason: '',
      category: '',
      liked: isLiked,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodReviewOverlayScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 이미지 + 몰 이름 + 좋아요 버튼 (Stack으로 겹침)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade100),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mallName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onLikeTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isLiked ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2) 상품명 + 설명 + 가격 + 리뷰 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.3,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(price)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (reviewCount != null && reviewCount! > 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '후기 $reviewCount',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // 모든 상품에 리뷰보기 버튼 표시
                          GestureDetector(
                            onTap: () => _openReviews(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '리뷰보기',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.deepPurple[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _RecipeGridItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final int viewCount;
  final String detailLink;
  final VoidCallback? onTap;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final int historyId;
  final int recipeId;

  const _RecipeGridItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.viewCount,
    required this.detailLink,
    this.onTap,
    this.isLiked = false,
    this.onLikeTap,
    required this.historyId,
    required this.recipeId,
  }) : super(key: key);

  static final FoodApi _foodApi = FoodApi();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // openRecipe API 비동기 호출 (recipeId가 0이 아닌 경우에만)
        if (recipeId != 0) {
          _foodApi.openRecipe(historyId.toString(), recipeId.toString());
        }
        final Uri url = Uri.parse(detailLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크를 열 수 없습니다.')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text(
                              NumberFormat('#,###').format(viewCount),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onLikeTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodsHistoryDetailScreenState extends State<FoodsHistoryDetailScreen> {
  late FoodsHistory _history;
  final HistoryRepository _repository = HistoryRepository();
  final LikeRepository _likeRepository = LikeRepository();
  bool _isRating = false;
  String? _selectedMall;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
  }

  List<String> get _mallNames {
    final Set<String> malls = {'전체'};
    for (var product in _history.recommendations) {
      malls.add(product.mallName);
    }
    return malls.toList();
  }

  List<FoodsProduct> get _filteredProducts {
    if (_selectedMall == null || _selectedMall == '전체') {
      return _history.recommendations;
    }
    return _history.recommendations.where((p) => p.mallName == _selectedMall).toList();
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required int count,
    List<Widget>? trailing,
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
              const Spacer(),
              if (trailing != null) ...trailing,
            ],
          ),
          if (trailing != null)
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

  String? _extractTag() {
    if (_history.ingredients?.isNotEmpty ?? false) {
      final ingredients = _history.ingredients!;
      if (ingredients.startsWith('[') && ingredients.endsWith(']')) {
        // [] 제거하고 반환
        final content = ingredients.substring(1, ingredients.length - 1).trim();
        // content가 비어있거나 "[]"인 경우 suggested 값을 사용
        if (content.isEmpty || content == "[]") {
          return _history.suggested;
        }
        return content.isNotEmpty ? content : null;
      }
      return ingredients;
    } else if (_history.suggested?.isNotEmpty ?? false) {
      return _history.suggested;
    }
    return null;
  }

  Future<void> _submitRating(int rating) async {
    if (_isRating) return;
    setState(() => _isRating = true);

    try {
      await _repository.postFoodRating(
        historyId: _history.id,
        rating: rating,
      );
      setState(() {
        _history = _history.copyWith(
          hasRating: true,
          myRating: rating,
        );
      });
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('평점 등록에 실패했습니다.')),
        );
      }
    } finally {
      setState(() => _isRating = false);
    }
  }

  Future<void> _handleLike(dynamic item) async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);

    try {
      if (item is FoodsProduct) {
        if (item.liked) {
          await _likeRepository.deleteLikeFood(
            historyId: _history.id,
            recommendationId: item.id.toString(),
            productId: item.productId,
            mallName: item.mallName,
          );
        } else {
          await _likeRepository.postLikeFood(
            historyId: _history.id,
            recommendationId: item.id.toString(),
            productId: item.productId,
            mallName: item.mallName,
          );
        }

        setState(() {
          _history = _history.copyWith(
            recommendations: _history.recommendations.map((p) {
              if (p.id == item.id) {
                return FoodsProduct(
                  id: p.id,
                  productId: p.productId,
                  productName: p.productName,
                  productPrice: p.productPrice,
                  productLink: p.productLink,
                  productImage: p.productImage,
                  productDescription: p.productDescription,
                  source: p.source,
                  mallName: p.mallName,
                  category: p.category,
                  reviewCount: p.reviewCount,
                  liked: !p.liked,
                );
              }
              return p;
            }).toList(),
          );
        });
      } else if (item is FoodsRecipe) {
        if (item.liked) {
          await _likeRepository.deleteLikeRecipe(
            historyId: _history.id,
            recipeId: item.id.toString(),
          );
        } else {
          await _likeRepository.postLikeRecipe(
            historyId: _history.id,
            recipeId: item.id.toString(),
          );
        }

        setState(() {
          _history = _history.copyWith(
            recipes: _history.recipes.map((r) {
              if (r.id == item.id) {
                return FoodsRecipe(
                  id: r.id,
                  recipeName: r.recipeName,
                  detailLink: r.detailLink,
                  recipeImage: r.recipeImage,
                  averageRating: r.averageRating,
                  reviewCount: r.reviewCount,
                  viewCount: r.viewCount,
                  liked: !r.liked,
                );
              }
              return r;
            }).toList(),
          );
        });
      }
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
    final hasRecommendations = _history.recommendations.isNotEmpty;
    final hasRecipes = _history.recipes.isNotEmpty;
    final tag = _extractTag();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _history);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: const Text('상세 히스토리',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context, _history),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 추천이유, 간단 조리법, 식재료 추천 섹션
                  if ((_history.suggestionReason != null && _history.suggestionReason!.trim().isNotEmpty && _history.suggestionReason!.trim() != '[]') || 
                       (_history.recipeSummary != null && _history.recipeSummary!.trim().isNotEmpty && _history.recipeSummary!.trim() != '[]') || 
                       (_history.requiredIngredients.isNotEmpty && _history.requiredIngredients.join(', ').trim().isNotEmpty && _history.requiredIngredients.join(', ').trim() != '[]'))
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_history.suggestionReason != null && _history.suggestionReason!.trim().isNotEmpty && _history.suggestionReason!.trim() != '[]')
                            _buildExpandableSection(
                              title: '알프레드의 추천이유',
                              content: _history.suggestionReason!,
                              icon: Icons.lightbulb_outline,
                              isExpanded: false,
                              onExpansionChanged: (_) {},
                            ),
                          if ((_history.suggestionReason != null && _history.suggestionReason!.trim().isNotEmpty && _history.suggestionReason!.trim() != '[]') && 
                               ((_history.recipeSummary != null && _history.recipeSummary!.trim().isNotEmpty && _history.recipeSummary!.trim() != '[]') || 
                                (_history.requiredIngredients.isNotEmpty && _history.requiredIngredients.join(', ').trim().isNotEmpty && _history.requiredIngredients.join(', ').trim() != '[]')))
                            const SizedBox(height: 16),
                          if (_history.recipeSummary != null && _history.recipeSummary!.trim().isNotEmpty && _history.recipeSummary!.trim() != '[]')
                            _buildExpandableSection(
                              title: '알프레드의 간단 조리법',
                              content: _history.recipeSummary!,
                              icon: Icons.restaurant_menu,
                              isRecipe: true,
                              isExpanded: false,
                              onExpansionChanged: (_) {},
                            ),
                          if ((_history.recipeSummary != null && _history.recipeSummary!.trim().isNotEmpty && _history.recipeSummary!.trim() != '[]') && 
                               (_history.requiredIngredients.isNotEmpty && _history.requiredIngredients.join(', ').trim().isNotEmpty && _history.requiredIngredients.join(', ').trim() != '[]'))
                            const SizedBox(height: 16),
                          if (_history.requiredIngredients.isNotEmpty && _history.requiredIngredients.join(', ').trim().isNotEmpty && _history.requiredIngredients.join(', ').trim() != '[]')
                            _buildExpandableSection(
                              title: '알프레드의 식재료 추천',
                              content: _history.requiredIngredients.join(', '),
                              icon: Icons.shopping_basket,
                              isExpanded: false,
                              onExpansionChanged: (_) {},
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 추천 상품 섹션
                  if (hasRecommendations) Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          title: '추천 상품',
                          icon: Icons.shopping_cart_outlined,
                          count: _filteredProducts.length,
                          trailing: const [],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredProducts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 280,
                            ),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _ProductGridItem(
                                imageUrl: product.productImage,
                                name: product.productName,
                                price: product.productPrice,
                                mallName: product.mallName,
                                reviewCount: product.reviewCount,
                                description: product.productDescription,
                                productLink: product.productLink,
                                isLiked: product.liked,
                                onLikeTap: () => _handleLike(product),
                                productId: product.productId,
                                source: product.source,
                                historyId: _history.id,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 추천 레시피 섹션
                  if (hasRecipes) Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          title: '추천 레시피',
                          icon: Icons.restaurant_menu,
                          count: _history.recipes.length,
                          trailing: null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 220,
                            ),
                            itemCount: _history.recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _history.recipes[index];
                              return _RecipeGridItem(
                                imageUrl: recipe.recipeImage,
                                name: recipe.recipeName,
                                rating: recipe.averageRating.toDouble(),
                                viewCount: recipe.viewCount,
                                detailLink: recipe.detailLink,
                                isLiked: recipe.liked,
                                onLikeTap: () => _handleLike(recipe),
                                historyId: _history.id,
                                recipeId: recipe.id ?? 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        "주인님 저의 추천에 평가를 내려주세요",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: _isRating ? null : () async {
                              final newRating = index + 1;
                              await _submitRating(newRating);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < (_history.myRating ?? 0) ? Icons.star : Icons.star_border,
                                size: 40,
                                color: _isRating ? Colors.grey : Colors.amber,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      if (_isRating) const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String content,
    required IconData icon,
    bool isRecipe = false,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
  }) {
    return Card(
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
              Icon(icon, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 24, thickness: 1),
            if (isRecipe)
              Column(
                children: content
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .split(RegExp(r'\s*\d+\.\s*'))
                    .where((step) => step.isNotEmpty)
                    .map((step) => step.trim())
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content
                    .split(',')
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.trim(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
} 