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

class _EventCardState extends State<EventCard> {
  late Event _event;
  final likeRepo = LikeRepository();

  @override
  void initState() {
    super.initState();
    _event = widget.event;
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
            SnackBar(content: Text('API 호출 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: InkWell(
          onTap: _openWebView,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 좌측 이미지 영역
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                          color: const Color(0xFFEEEEEE),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[400],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 0.6),
                            borderRadius: BorderRadius.circular(6),
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
                  padding: const EdgeInsets.all(10),
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () async {
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
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('상세보기', 
                              style: TextStyle(fontSize: 10, color: Colors.blue)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_event.location} · ${_event.hospitalName}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildPriceSection(),
                                const SizedBox(height: 2),
                                _buildRatingSection(),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _event.liked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: _event.liked ? Colors.red : Colors.grey,
                            ),
                            onPressed: _toggleLike,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
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
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_event.discountRate > 0)
          Text(
            '${_event.discountRate}%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        if (_event.discountRate > 0) const SizedBox(width: 4),
        Text(
          '${formatter.format(_event.discountedPrice)}원',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
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
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(width: 2),
        Text(
          '(${_event.ratingCount})',
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }
}
