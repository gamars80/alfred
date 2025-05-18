import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/common/dio/dio_client.dart';
import '../../../auth/presentation/event_image_viewer_screen.dart';
import '../../../auth/presentation/event_multi_images_viewer_screen.dart';
import '../../model/popular_event.dart';

class PopularEventCard extends StatelessWidget {
  final PopularEvent event;
  final int rank;

  const PopularEventCard({
    super.key,
    required this.event,
    required this.rank,
  });


  Future<void> _openEvent() async {
    final String url = event.source == '바비톡'
        ? 'https://web.babitalk.com/events/${event.eventId}'
        : 'https://www.gangnamunni.com/events/${event.eventId}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      final response = await DioClient.dio.get(
        '/api/events/${event.eventId}/detail-image',
      );
      final List<String> imageUrls = List<String>.from(response.data ?? []);

      if (imageUrls.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiImageWebViewScreen(imageUrls: imageUrls),
          ),
        );
      } else {
        debugPrint('Detail images empty for event ID ${event.eventId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 불러오지 못했습니다.')),
        );
      }
    } catch (e, stack) {
      debugPrint('Error fetching detail images: $e');
      debugPrintStack(stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 오류: ${e.toString()}')),
      );
    }
  }

  void _onDetailPressed(BuildContext context) async {
    if (event.source == '바비톡') {
      // 바비톡은 단일 detailImage URL로 이미지 화면 띄우기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageWebViewScreen(imageUrl: event.detailImage),
        ),
      );
    } else {
      // 기타는 API 호출 후 여러 이미지
      await _openDetailImage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return GestureDetector(
      onTap: () => _openEvent(),
      child: Container(
        width: 240,
        height: 260,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 + 랭킹
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: event.thumbnailUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TOP $rank',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // 정보 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${event.hospitalName} • ${event.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onDetailPressed(context),
                        child: Text(
                          '상세',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '₩${formatter.format(int.tryParse(event.discountedPrice) ?? 0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${event.discountRate.toInt()}%↓)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
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
