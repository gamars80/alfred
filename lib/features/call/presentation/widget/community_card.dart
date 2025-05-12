import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../like/data/like_repository.dart';
import '../../model/community_post.dart';
import 'gallery_page.dart';
import 'dart:ui';

class CommunityCard extends StatefulWidget {
  final CommunityPost post;
  final String source;
  final int historyCreatedAt;
  final bool initialLiked;

  const CommunityCard({
    Key? key,
    required this.post,
    required this.source,
    required this.historyCreatedAt,
    required this.initialLiked,
  }) : super(key: key);

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  static const _limit = 100;
  late bool isLiked;
  final LikeRepository _likeRepo = LikeRepository();

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;
    debugPrint('🕒 CommunityCard.init: historyCreatedAt=${widget.historyCreatedAt}, initialLiked=${widget.initialLiked}');
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.post.content;
    final isLong = content.length > _limit;
    final displayText = isLong ? content.substring(0, _limit) + '...' : content;

    return RepaintBoundary(
      child: Card(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color.fromRGBO(128, 128, 128, 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: const TextStyle(fontSize: 10, height: 1.4, color: Colors.black87),
              ),
              if (isLong) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // source에 따라 베이스 URL을 분기
                        final baseUrl = widget.source == '강남언니'
                            ? 'https://www.gangnamunni.com/community/'
                            : 'https://web.babitalk.com/community/';
                        final uri = Uri.parse('$baseUrl${widget.post.id}');

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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
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
                            size: 20,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (widget.post.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.post.photoUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final url = widget.post.photoUrls[i];
                      final showBlur = i > 0 && widget.post.photoUrls.length > 1;

                      return GestureDetector(
                        onTap: () async {
                          if (showBlur) {
                            final uri = Uri.parse('https://www.gangnamunni.com/community/\${widget.post.id}');
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
                                  images: widget.post.photoUrls,
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
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (showBlur)
                              Positioned.fill(
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
              Row(
                children: [
                  _IconText(
                    icon: Icons.thumb_up,
                    count: widget.post.commentCount,
                  ),
                  const SizedBox(width: 24),
                  _IconText(
                    icon: Icons.comment,
                    count: widget.post.commentCount,
                  ),
                  const SizedBox(width: 24),
                  _IconText(
                    icon: Icons.visibility,
                    count: widget.post.viewCount,
                  ),
                  const Spacer(),
                  Text(
                    '출처: ${widget.source}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    setState(() => isLiked = !isLiked);
    debugPrint('▶️ toggleLike: historyCreatedAt=${widget.historyCreatedAt}, postId=${widget.post.id}, isLiked=$isLiked');
    try {
      if (isLiked) {
        await _likeRepo.postLikeBeautyCommunity(
          historyCreatedAt: widget.historyCreatedAt,
          beautyCommunityId: widget.post.id.toString(),
          source: widget.source,
        );
      } else {
        await _likeRepo.deleteLikeBeautyCommunity(
          historyCreatedAt: widget.historyCreatedAt,
          beautyCommunityId: widget.post.id.toString(),
          source: widget.source,
        );
      }
    } catch (e) {
      setState(() => isLiked = !isLiked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
      );
    }
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconText({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
