import 'package:flutter/material.dart';
import 'package:alfred_clean/features/history/model/care_community_post.dart';
import 'package:alfred_clean/common/util/date_formatter.dart';
import 'package:alfred_clean/features/like/data/like_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class CareCommunityCard extends StatefulWidget {
  final CareCommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeToggle;
  final int historyId;

  const CareCommunityCard({
    Key? key,
    required this.post,
    required this.historyId,
    this.onTap,
    this.onLikeToggle,
  }) : super(key: key);

  @override
  State<CareCommunityCard> createState() => _CareCommunityCardState();
}

class _CareCommunityCardState extends State<CareCommunityCard> {
  bool _isLiked = false;
  bool _isLikeLoading = false;
  final LikeRepository _likeRepository = LikeRepository();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.liked;
  }

  Future<void> _openCommunityPost() async {
    final url = 'https://unnie.moneple.com/beautyroutine/${widget.post.postId}?from=community';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleLikeToggle() async {
    if (_isLikeLoading) return;
    
    setState(() {
      _isLikeLoading = true;
      _isLiked = !_isLiked;
    });

    try {
      if (_isLiked) {
        await _likeRepository.postLikeCareCommunity(
          historyId: widget.historyId,
          communityId: widget.post.id.toString(),
          source: widget.post.source,
        );
      } else {
        await _likeRepository.deleteLikeCareCommunity(
          historyId: widget.historyId,
          communityId: widget.post.id.toString(),
          source: widget.post.source,
        );
      }
      
      widget.onLikeToggle?.call();
    } catch (e) {
      // 에러 발생 시 상태 롤백
      setState(() {
        _isLiked = !_isLiked;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? _openCommunityPost,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커뮤니티 이미지 (클릭 가능)
            GestureDetector(
              onTap: _openCommunityPost,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Stack(
                    children: [
                      (widget.post.image.isNotEmpty)
                          ? Image.network(
                              widget.post.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.forum_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                      // 출처 표시
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '출처: 언니의 파우치',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 커뮤니티 정보
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 하단 정보
                  Row(
                    children: [
                      // 좋아요 수
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _isLikeLoading ? null : _handleLikeToggle,
                            child: _isLikeLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                    ),
                                  )
                                : Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 12,
                                    color: _isLiked ? Colors.red : Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.post.likes}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      
                      // 조회수
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 10,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.post.views}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      
                      // 커뮤니티 아이콘
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          size: 10,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 