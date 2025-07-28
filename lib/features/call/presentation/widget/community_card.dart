import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../like/data/like_repository.dart';
import '../../model/community_post.dart';
import 'gallery_page.dart';
import 'dart:ui';

// 🎨 Modern Community Card Theme
class CommunityCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final int count;

  _IconText({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CommunityCardTheme.primaryGradientStart.withOpacity(0.1),
            CommunityCardTheme.primaryGradientEnd.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CommunityCardTheme.primaryGradientStart.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CommunityCardTheme.primaryGradientStart),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CommunityCardTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityCard extends StatefulWidget {
  final CommunityPost post;
  final String source;
  final int historyCreatedAt;
  final bool initialLiked;

  final void Function(CommunityPost updatedPost)? onLikedChanged;

  const CommunityCard({
    Key? key,
    required this.post,
    required this.source,
    required this.historyCreatedAt,
    required this.initialLiked,
    this.onLikedChanged,
  }) : super(key: key);

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard>
    with SingleTickerProviderStateMixin {
  static const _limit = 100;
  late bool isLiked;
  late CommunityPost _post;
  final LikeRepository _likeRepo = LikeRepository();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;
    _post = widget.post;
    
    _animationController = AnimationController(
      duration: CommunityCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    debugPrint('🕒 CommunityCard.init: historyCreatedAt=${widget.historyCreatedAt}, initialLiked=${widget.initialLiked}');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _post.content;
    final isLong = content.length > _limit;
    final displayText = isLong ? content.substring(0, _limit) + '...' : content;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CommunityCardTheme.cardBackground,
                  borderRadius: BorderRadius.circular(CommunityCardTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: CommunityCardTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isLong) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final baseUrl = widget.source == '강남언니'
                                  ? 'https://www.gangnamunni.com/community/'
                                  : 'https://web.babitalk.com/community/';
                              final uri = Uri.parse('$baseUrl${_post.id}');

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('URL을 열 수 없습니다.')),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    CommunityCardTheme.secondaryGradientStart,
                                    CommunityCardTheme.secondaryGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: CommunityCardTheme.secondaryGradientStart.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '[더보기]',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isLiked
                                      ? [Colors.red.shade400, Colors.red.shade600]
                                      : [Colors.grey.shade300, Colors.grey.shade400],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isLiked ? Colors.red : Colors.grey).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_post.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _post.photoUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final url = _post.photoUrls[i];
                            final showBlur = i > 0 && _post.photoUrls.length > 1;

                            return GestureDetector(
                              onTap: () async {
                                if (showBlur) {
                                  final baseUrl = widget.source == '강남언니'
                                      ? 'https://www.gangnamunni.com/community/'
                                      : 'https://web.babitalk.com/community/';
                                  final uri = Uri.parse('$baseUrl${_post.id}');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('URL을 열 수 없습니다.')),
                                    );
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GalleryPage(
                                        images: _post.photoUrls,
                                        initialIndex: i,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      ColorFiltered(
                                        colorFilter: showBlur
                                            ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                                            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                        child: ImageFiltered(
                                          imageFilter: showBlur
                                              ? ImageFilter.blur(sigmaX: 6, sigmaY: 6)
                                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            fadeInDuration: const Duration(milliseconds: 200),
                                            memCacheWidth: 240,
                                            placeholder: (context, url) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade200,
                                                    Colors.grey.shade100,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade300,
                                                    Colors.grey.shade200,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.error,
                                                color: Colors.grey,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (showBlur)
                                        Positioned.fill(
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withOpacity(0.8),
                                                    Colors.black.withOpacity(0.6),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Click',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _IconText(icon: Icons.thumb_up, count: _post.thumbUpCount),
                          const SizedBox(width: 12),
                          _IconText(icon: Icons.comment, count: _post.commentCount),
                          const SizedBox(width: 12),
                          _IconText(icon: Icons.visibility, count: _post.viewCount),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CommunityCardTheme.textSecondary.withOpacity(0.1),
                                  CommunityCardTheme.textSecondary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '출처: ${widget.source}',
                              style: TextStyle(
                                fontSize: 11,
                                color: CommunityCardTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      _post = _post.copyWith(liked: isLiked);
    });

    widget.onLikedChanged?.call(_post);
    debugPrint('▶️ toggleLike: historyCreatedAt=${widget.historyCreatedAt}, postId=${_post.id}, isLiked=$isLiked');

    try {
      if (isLiked) {
        await _likeRepo.postLikeBeautyCommunity(
          historyCreatedAt: widget.historyCreatedAt,
          beautyCommunityId: _post.id.toString(),
          source: widget.source,
        );
      } else {
        await _likeRepo.deleteLikeBeautyCommunity(
          historyCreatedAt: widget.historyCreatedAt,
          beautyCommunityId: _post.id.toString(),
          source: widget.source,
        );
      }
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        _post = _post.copyWith(liked: isLiked); // 롤백도 같이
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
      );
    }
  }
}
