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

  Future<void> _openWebView(BuildContext context) async {
    final sourceEncoded = Uri.encodeComponent(event.source);
    final apiPath = '/api/events/${event.eventId}/${event.historyAddedAt}/$sourceEncoded/open';

    try {
      final response = await DioClient.dio.post(apiPath);

      if (response.statusCode == 200) {
        final url = event.source == '바비톡'
            ? 'https://web.babitalk.com/events/${event.eventId}'
            : 'https://www.gangnamunni.com/events/${event.eventId}';

        final uri = Uri.parse(url);
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL을 열 수 없습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API 호출 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 연결 중 오류가 발생했습니다.')),
      );
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openWebView(context),
            child: _buildImageSection(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Color(0xFFFF4B6E), size: 16),
                      onPressed: onUnlike,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${event.location} · ${event.hospitalName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openDetailImage(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 14),
                      ),
                      child: const Text(
                        '상세보기',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageUrl = (event.thumbnailUrls?.isNotEmpty ?? false)
        ? event.thumbnailUrls!.first
        : 'https://via.placeholder.com/300x300.png?text=No+Image';

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFFF5F5F5),
              height: 140,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFF5F5F5),
              height: 140,
              child: const Icon(Icons.broken_image, color: Color(0xFF666666)),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              event.source,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(NumberFormat formatter) {
    return Row(
      children: [
        if (event.discountRate > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4B6E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '${event.discountRate}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF4B6E),
              ),
            ),
          ),
        if (event.discountRate > 0) const SizedBox(width: 2),
        Text(
          '${formatter.format(event.discountedPrice)}원',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 10, color: Color(0xFFFFB800)),
          const SizedBox(width: 1),
          Text(
            event.rating,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 1),
          Text(
            '(${event.ratingCount})',
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
