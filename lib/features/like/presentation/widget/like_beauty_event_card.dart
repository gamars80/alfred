import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/event_image_viewer_screen.dart';
import '../../../auth/presentation/event_multi_images_viewer_screen.dart';
import '../../../like/model/like_beauty_event.dart';

class LikedBeautyEventCard extends StatelessWidget {
  final LikedBeautyEvent event;
  final VoidCallback onUnlike;

  const LikedBeautyEventCard({
    super.key,
    required this.event,
    required this.onUnlike,
  });

  void _openWebView(BuildContext context) async {
    final url = event.source == '바비톡'
        ? 'https://web.babitalk.com/events/${event.eventId}'
        : 'https://www.gangnamunni.com/events/${event.eventId}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openDetailImage(BuildContext context) async {
    try {
      if (event.source == '바비톡') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageWebViewScreen(imageUrl: event.detailImage),
          ),
        );
      } else {
        final response = await DioClient.dio.get('/api/events/${event.eventId}/detail-image');
        final List<String> imageUrls = List<String>.from(response.data ?? []);

        if (imageUrls.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiImageWebViewScreen(imageUrls: imageUrls),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지를 불러오지 못했습니다.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openWebView(context),
            child: _buildImageSection(context),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openDetailImage(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('상세보기', style: TextStyle(fontSize: 9, color: Colors.blue)),
                    )
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${event.location} · ${event.hospitalName}',
                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                      onPressed: onUnlike,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriceSection(formatter),
                    _buildRatingSection(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageUrl = (event.thumbnailUrls?.isNotEmpty ?? false)
        ? event.thumbnailUrls!.first
        : 'https://via.placeholder.com/300x300.png?text=No+Image';

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          height: 160,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey,
          height: 160,
          child: const Icon(Icons.broken_image, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPriceSection(NumberFormat formatter) {
    return Row(
      children: [
        if (event.discountRate > 0)
          Text(
            '${event.discountRate}%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        if (event.discountRate > 0) const SizedBox(width: 4),
        Text(
          '${formatter.format(event.discountedPrice)}원',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          event.rating,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          '(${event.ratingCount})',
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }
}
