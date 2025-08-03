// lib/features/home/presentation/widget/popular_weekly_event_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';
import '../../model/popular_weekly_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PopularWeeklyEventCardTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 배경 색상
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double imageRadius = 16.0;
}

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

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        event.source,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          size: 16,
          color: Color(0xFFFFD700),
        ),
        const SizedBox(width: 4),
        Text(
          '${event.rating.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${event.ratingCount})',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        if (event.discountRate > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PopularWeeklyEventCardTheme.primaryGradientStart,
                  PopularWeeklyEventCardTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${event.discountRate.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            _formatPrice(event.discountedPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 섹션
          Stack(
            children: [
              GestureDetector(
                onTap: () => _openEvent(context),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PopularWeeklyEventCardTheme.imageRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(PopularWeeklyEventCardTheme.imageRadius),
                    child: CachedNetworkImage(
                      imageUrl: event.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PopularWeeklyEventCardTheme.primaryGradientStart.withOpacity(0.1),
                              PopularWeeklyEventCardTheme.primaryGradientEnd.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(PopularWeeklyEventCardTheme.imageRadius),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 32,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PopularWeeklyEventCardTheme.primaryGradientStart.withOpacity(0.1),
                              PopularWeeklyEventCardTheme.primaryGradientEnd.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(PopularWeeklyEventCardTheme.imageRadius),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 32,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 소스 배지
              Positioned(
                top: 8,
                left: 8,
                child: _buildSourceBadge(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 병원명
          Text(
            event.hospitalName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 가격 섹션
          _buildPriceSection(),
          
          const SizedBox(height: 8),
          
          // 평점 섹션
          _buildRatingSection(),
        ],
      ),
    );
  }
}
