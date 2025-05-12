import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/like_beauty_community.dart';

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

            // ── 여기에 [더보기] 버튼 추가 ──
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

            if ((item.photoUrls ?? []).isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.photoUrls!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.photoUrls![i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
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
