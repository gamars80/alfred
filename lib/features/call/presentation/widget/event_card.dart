import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/common/dio/dio_client.dart';

import '../../../auth/presentation/event_image_viewer_screen.dart';
import '../../../auth/presentation/event_multi_images_viewer_screen.dart';
import '../../../like/data/like_repository.dart';
import '../../model/event.dart';
import '../event_webview_screen.dart';

// 🎨 Modern Event Card Theme
class EventCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class EventCard extends StatefulWidget {
  final Event event;
  final int historyCreatedAt;
  final void Function(Event updated)? onLikedChanged;

  const EventCard({
    Key? key,
    required this.event,
    required this.historyCreatedAt,
    this.onLikedChanged,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  late Event _event;
  final likeRepo = LikeRepository();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    
    _animationController = AnimationController(
      duration: EventCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final isNowLiked = !_event.liked;

    setState(() {
      _event = _event.copyWith(liked: isNowLiked);
    });

    try {
      if (isNowLiked) {
        await likeRepo.postLikeBeautyEvent(
          historyCreatedAt: widget.historyCreatedAt,
          eventId: _event.id.toString(),
          source: _event.source,
        );
      } else {
        await likeRepo.deleteLikeBeautyEvent(
          historyCreatedAt: widget.historyCreatedAt,
          eventId: _event.id.toString(),
          source: _event.source,
        );
      }

      widget.onLikedChanged?.call(_event);
    } catch (e) {
      setState(() {
        _event = _event.copyWith(liked: !isNowLiked);
      });
    }
  }

  Future<void> _openWebView() async {
    final apiPath = '/api/events/${_event.id}/${widget.historyCreatedAt}/${Uri.encodeComponent(_event.source)}/open';

    try {
      final response = await DioClient.dio.post(apiPath);

      if (response.statusCode == 200) {
        String url;
        debugPrint('source::::::::::::::::::::::${_event.source}');
        debugPrint('detailLink::::::::::::::::::::::${_event.detailLink}');
        if (_event.source == '여신티켓') {
          url = _event.detailLink ?? 'https://www.gangnamunni.com/events/${_event.id}';
        } else if (_event.source == '바비톡') {
          url = 'https://web.babitalk.com/events/${_event.id}';
        } else {
          url = 'https://www.gangnamunni.com/events/${_event.id}';
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventWebViewScreen(url: url),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EventCardTheme.errorColor,
                      EventCardTheme.errorColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'API 호출 실패: ${response.statusCode}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EventCardTheme.errorColor,
                    EventCardTheme.errorColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '오류가 발생했습니다: $e',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    }
  }

  Future<void> _openDetailImage(BuildContext context) async {
    try {
      if (_event.source == '여신티켓') {
        // Extract ref parameter from detailLink
        String? ref;
        if (_event.detailLink != null) {
          final uri = Uri.parse(_event.detailLink!);
          ref = uri.queryParameters['ref'];
        }

        final response = await DioClient.dio.get(
          '/api/events/${_event.id}/yeoshin-detail-image',
          queryParameters: {'ref': ref},
        );
        final List<String> imageUrls = List<String>.from(response.data ?? []);

        if (imageUrls.isNotEmpty && mounted) {
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
      } else {
        final response = await DioClient.dio.get('/api/events/${_event.id}/detail-image');
        final List<String> imageUrls = List<String>.from(response.data ?? []);

        if (imageUrls.isNotEmpty && mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('EventCard build: id=${widget.event.id}, source=${widget.event.source}');
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: EventCardTheme.cardBackground,
                borderRadius: BorderRadius.circular(EventCardTheme.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: InkWell(
                  onTap: _openWebView,
                  borderRadius: BorderRadius.circular(EventCardTheme.borderRadius),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 좌측 이미지 영역
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(EventCardTheme.borderRadius),
                          bottomLeft: Radius.circular(EventCardTheme.borderRadius),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 110,
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: _event.thumbnailUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                                fadeInDuration: const Duration(milliseconds: 0),
                                placeholderFadeInDuration: const Duration(milliseconds: 0),
                                memCacheHeight: (110 * MediaQuery.of(context).devicePixelRatio).toInt(),
                                memCacheWidth: (MediaQuery.of(context).size.width * 0.35 * MediaQuery.of(context).devicePixelRatio).toInt(),
                                maxHeightDiskCache: (110 * 2).toInt(),
                                maxWidthDiskCache: (MediaQuery.of(context).size.width * 0.35 * 2).toInt(),
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade200,
                                        Colors.grey.shade100,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade300,
                                        Colors.grey.shade200,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.error, color: Colors.grey),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _event.source,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 우측 정보 영역
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _event.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: EventCardTheme.textPrimary,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      if (_event.source == '바비톡') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ImageWebViewScreen(imageUrl: _event.detailImage),
                                          ),
                                        );
                                      } else {
                                        await _openDetailImage(context);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            EventCardTheme.secondaryGradientStart,
                                            EventCardTheme.secondaryGradientEnd,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: EventCardTheme.secondaryGradientStart.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        '상세보기',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      EventCardTheme.textSecondary.withOpacity(0.1),
                                      EventCardTheme.textSecondary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_event.location} · ${_event.hospitalName}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: EventCardTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildPriceSection(),
                                        const SizedBox(height: 4),
                                        _buildRatingSection(),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _toggleLike,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _event.liked
                                              ? [Colors.red.shade400, Colors.red.shade600]
                                              : [Colors.grey.shade300, Colors.grey.shade400],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_event.liked ? Colors.red : Colors.grey).withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          _event.liked ? Icons.favorite : Icons.favorite_border,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_event.discountRate > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EventCardTheme.warningColor.withOpacity(0.2),
                  EventCardTheme.warningColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_event.discountRate}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: EventCardTheme.warningColor,
              ),
            ),
          ),
        if (_event.discountRate > 0) const SizedBox(width: 4),
        Text(
          '${formatter.format(_event.discountedPrice)}원',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: EventCardTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    if (_event.rating == null || _event.rating == 0 || _event.ratingCount == 0) {
      return const SizedBox.shrink();
    }
    
    final ratingStr = (_event.rating ?? 0.0).toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 12, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          ratingStr,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: EventCardTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '(${_event.ratingCount})',
          style: TextStyle(
            fontSize: 9,
            color: EventCardTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
