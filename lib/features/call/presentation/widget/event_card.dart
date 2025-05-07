import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../../hospital/presentation/event_image_viewer_screen.dart';
import '../../../hospital/presentation/event_multi_images_viewer_screen.dart';
import '../../model/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  Future<void> _openWebView() async {
    final url = 'https://www.gangnamunni.com/events/${event.id}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      debugPrint('[EventCard] 요청 ID: ${event.id}');

      final response = await DioClient.dio.get(
        '/api/events/${event.id}/detail-image',
      );

      // 응답 데이터가 List<dynamic> 형식이라고 가정
      final List<dynamic> data = response.data;

      // String만 추출
      final List<String> imageUrls = data.whereType<String>().toList();

      debugPrint('[EventCard] 응답: $imageUrls');

      if (imageUrls.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiImageWebViewScreen(imageUrls: imageUrls),
          ),
        );
      } else {
        debugPrint('[EventCard] Empty image list');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 불러오지 못했습니다.')),
        );
      }
    } catch (e) {
      debugPrint('[EventCard] Error fetching detail-image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 오류가 발생했습니다.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(onTap: _openWebView, child: _buildThumbnail(context)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (event.source == '바비톡') {
                          // 바비톡인 경우 event.detailImage 사용
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageWebViewScreen(
                                imageUrl: event.detailImage,
                              ),
                            ),
                          );
                        } else {
                          // 그 외는 API 호출
                          await _openDetailImage(context);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: const Text(
                        '상세보기',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.location} · ${event.hospitalName}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildPriceSection(), _buildRatingSection()],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: event.thumbnailUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            memCacheWidth: MediaQuery.of(context).size.width.toInt(),
            fadeInDuration: const Duration(milliseconds: 300),
            placeholder: (context, url) => Container(
              width: double.infinity,
              height: 160,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              width: double.infinity,
              height: 160,
              color: Colors.grey[400],
              child: const Icon(Icons.error, color: Colors.white),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.source,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat('#,###', 'ko_KR');
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final ratingStr = (event.rating ?? 0.0).toStringAsFixed(1);

    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          ratingStr,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(width: 4),
        Text(
          '(${event.ratingCount})',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
