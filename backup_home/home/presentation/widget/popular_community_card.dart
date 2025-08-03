import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 외부 브라우저 열기용
import '../../model/popular_community.dart';

class PopularCommunityCard extends StatelessWidget {
  final PopularCommunity community;
  final int rank;
  final VoidCallback? onTap;

  const PopularCommunityCard({
    super.key,
    required this.community,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = community.photoUrls.isNotEmpty;
    final imageUrl = hasImage ? community.photoUrls.first : null;

    return GestureDetector(
      onTap: () async {
        final baseUrl = community.source == '강남언니'
            ? 'https://www.gangnamunni.com/community/'
            : 'https://web.babitalk.com/community/';
        final url = '$baseUrl${community.communityId}';

        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크를 열 수 없습니다.')),
            );
          }
        }
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'TOP $rank',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              community.content.replaceAll('\r\n', '\n').trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  community.source,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (community.keyword != null &&
                    community.keyword!.isNotEmpty)
                  Text(
                    community.keyword!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
