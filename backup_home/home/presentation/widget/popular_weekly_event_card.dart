// lib/features/home/presentation/widget/popular_weekly_event_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../model/popular_weekly_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PopularWeeklyEventCard extends StatelessWidget {
  final PopularWeeklyEvent event;

  const PopularWeeklyEventCard({super.key, required this.event});

  String _formatPrice(String price) {
    try {
      final number = int.parse(price);
      return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(number);
    } catch (_) {
      return '$price원';
    }
  }

  Future<void> _openEvent(BuildContext context) async {
    // 3) 히스토리 생성 시점 정보가 PopularEvent 모델에 있다고 가정
    final sourceEncoded = Uri.encodeComponent(event.source);
    final apiPath = '/api/events/${event.eventId}/${event.historyAddedAt}/$sourceEncoded/open/${event.userId}';
    debugPrint("apiPath:::::::::::::::::::::$apiPath");
    try {
      final response = await DioClient.dio.post(apiPath);
      debugPrint("response.statusCode:::::::::::::${response.statusCode}");

      if (response.statusCode == 200) {
        final url = event.source == '바비톡'
            ? 'https://web.babitalk.com/events/${event.eventId}'
            : 'https://www.gangnamunni.com/events/${event.eventId}';

        final uri = Uri.parse(url);
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,  // 앱 내 웹뷰로 열기
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 이미지 + 좌측 상단 source 라벨
          Stack(
            children: [
              GestureDetector(
                onTap: () => _openEvent(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: event.thumbnailUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    event.source,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 병원명
          Text(
            event.hospitalName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // 할인율 + 가격
          Row(
            children: [
              if (event.discountRate > 0)
                Text(
                  '${event.discountRate.toInt()}%',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                _formatPrice(event.discountedPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // 평점
          Text(
            '⭐ ${event.rating.toStringAsFixed(1)} (${event.ratingCount})',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
