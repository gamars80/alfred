import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../like/data/like_repository.dart';
import '../../model/community_post.dart';
import 'gallery_page.dart';
import 'dart:ui';

class _IconText extends StatelessWidget {
  final IconData icon;
  final int count;

  const _IconText({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE091B3)),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
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

class _CommunityCardState extends State<CommunityCard> {
  static const _limit = 100;
  late bool isLiked;
  late CommunityPost _post;
  final LikeRepository _likeRepo = LikeRepository();

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;
    _post = widget.post;
    debugPrint('🕒 CommunityCard.init: historyCreatedAt=${widget.historyCreatedAt}, initialLiked=${widget.initialLiked}');
  }

  @override
  Widget build(BuildContext context) {
    final content = _post.content;
    final isLong = content.length > _limit;
    final displayText = isLong ? content.substring(0, _limit) + '...' : content;

    return RepaintBoundary(
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color.fromRGBO(128, 128, 128, 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              if (isLong) ...[
                const SizedBox(height: 4),
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
                      child: const Text(
                        '[더보기]',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE091B3),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 24,
                            color: isLiked ? const Color(0xFFFF4D6D) : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (_post.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _post.photoUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final url = _post.photoUrls[i];
                      final showBlur = i > 0 && _post.photoUrls.length > 1;

                      return GestureDetector(
                        onTap: () async {
                          if (showBlur) {
                            final uri = Uri.parse('https://www.gangnamunni.com/community/${_post.id}');
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
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ColorFiltered(
                                colorFilter: showBlur
                                    ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                child: ImageFiltered(
                                  imageFilter: showBlur
                                      ? ImageFilter.blur(sigmaX: 6, sigmaY: 6)
                                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(milliseconds: 200),
                                    memCacheWidth: 192,
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (showBlur)
                              const Positioned.fill(
                                child: Center(
                                  child: Text(
                                    'Click',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _IconText(icon: Icons.thumb_up, count: _post.thumbUpCount),
                    const SizedBox(width: 24),
                    _IconText(icon: Icons.comment, count: _post.commentCount),
                    const SizedBox(width: 24),
                    _IconText(icon: Icons.visibility, count: _post.viewCount),
                    const SizedBox(width: 16),
                    Text(
                      '출처: ${widget.source}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
