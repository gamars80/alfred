import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
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
