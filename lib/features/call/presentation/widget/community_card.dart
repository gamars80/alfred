import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/community_post.dart';
import 'gallery_page.dart';

class CommunityCard extends StatefulWidget {
  final CommunityPost post;
  const CommunityCard({Key? key, required this.post}) : super(key: key);

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  static const _limit = 100;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.post.content;
    final isLong = content.length > _limit;
    final displayText = isLong && !_isExpanded
        ? content.substring(0, _limit) + '...'
        : content;

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
                style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87),
              ),
              if (isLong) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? '[접기]' : '[더보기]',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryPage(
                                images: widget.post.photoUrls,
                                initialIndex: i,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
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
                    count: widget.post.thumbUpCount,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
