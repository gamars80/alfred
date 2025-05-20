import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/like_beauty_community.dart';
import '../../../call/presentation/widget/gallery_page.dart'; // GalleryPage 경로는 실제 경로에 맞게 조정

class BeautyCommunityLikedCard extends StatelessWidget {
  final LikedBeautyCommunity item;
  final VoidCallback onUnlike;

  const BeautyCommunityLikedCard({
    super.key,
    required this.item,
    required this.onUnlike,
  });

  @override
  Widget build(BuildContext context) {
    final contentPreview = item.content.length > 100
        ? item.content.substring(0, 100) + '...'
        : item.content;

    Future<void> _openDetail() async {
      final baseUrl = item.source == '강남언니'
          ? 'https://gangnamunni.com/community/'
          : 'https://web.babitalk.com/community/';
      final uri = Uri.parse('$baseUrl${item.beautyCommunityId}');
      debugPrint("uri:::::::::::::::::::::::::::::::::::::::$uri");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL을 열 수 없습니다.')),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentPreview,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _openDetail,
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
            const SizedBox(height: 8),

            // ✅ 이미지 섹션
            if ((item.photoUrls ?? []).isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.photoUrls!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final url = item.photoUrls![i];
                    final showBlur = i > 0 && item.photoUrls!.length > 1;

                    return GestureDetector(
                      onTap: () async {
                        if (showBlur) {
                          await _openDetail();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryPage(
                                images: item.photoUrls!,
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

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '출처: ${item.source}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                GestureDetector(
                  onTap: onUnlike,
                  child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
