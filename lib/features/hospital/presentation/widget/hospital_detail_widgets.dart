import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../auth/presentation/webview_screen.dart';
import '../../model/hospital_detail_model.dart';
import '../event_image_viewer_screen.dart';
import '../youtube_play_screen.dart';

class HospitalImageCarousel extends StatelessWidget {
  final List<String> images;

  const HospitalImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => CachedNetworkImage( // ✅ 캐싱 적용
          imageUrl: images[i],
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
    );
  }
}

void _openExternalWebView(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('외부 브라우저를 열 수 없습니다')),
    );
  }
}

class HospitalEventList extends StatelessWidget {
  final List<Event> events;
  final int hospitalId;

  const HospitalEventList({
    super.key,
    required this.events,
    required this.hospitalId,
  });

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '이벤트',
            style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        ...events.map((event) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (event.bannerImage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageWebViewScreen(
                        imageUrl: event.image, // 또는 bannerImage 등 실제 URL
                      ),
                    ),
                  );
                }
              },
              child: Card(
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 썸네일 (3)
                      Flexible(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: event.bannerImage != null
                              ? CachedNetworkImage( // ✅ 캐싱 적용
                            imageUrl: event.bannerImage!,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (_, __, ___) => const Icon(Icons.error),
                          )
                              : Container(
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 텍스트 영역 (7)
                      Flexible(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${event.rating}⭐️ · ${event.reviewCount}건',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_formatPrice(event.discountPrice)}원',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.discountRate}% 할인',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
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
              ),
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final url = 'https://web.babitalk.com/hospitals/$hospitalId?tab=event&category_type=SURGERY';
                _openExternalWebView(context, url);
              },
              child: const Text(
                '이벤트 더 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class HospitalReviewList extends StatelessWidget {
  final List<Review> reviews;
  final int hospitalId;

  const HospitalReviewList({super.key, required this.reviews, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '리뷰',
            style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        ...reviews.map((review) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Card(
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 평점 표시
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${review.rating}점',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 리뷰 텍스트
                    Text(
                      review.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                    if (review.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: review.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage( // ✅ 캐싱 적용
                                imageUrl: review.images[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (_, __, ___) => const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final url = 'https://web.babitalk.com/hospitals/$hospitalId?tab=review&category_type=SURGERY';
                _openExternalWebView(context, url);
              },
              child: const Text(
                '이벤트 더 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class HospitalDoctorList extends StatelessWidget {
  final List<Doctor> doctors;
  final int hospitalId;

  const HospitalDoctorList({super.key, required this.doctors, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '의사정보',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ...doctors.map((doctor) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Card(
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 사진
                    ClipOval(
                      child: CachedNetworkImage( // ✅ 캐싱 적용
                        imageUrl: doctor.profilePhoto,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 텍스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이름 + 포지션
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: doctor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${doctor.position}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // 전문의 / 병원 정보
                          if (doctor.specialist != null)
                            Text(
                              doctor.specialist!,
                              style: const TextStyle(fontSize: 8, color: Colors.black54),
                            ),
                          const SizedBox(height: 6),
                          // 해시태그 subject (Wrap으로 자동 줄바꿈)
                          if (doctor.subject.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: doctor.subject.map((s) {
                                return Text(
                                  '#$s',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.deepPurple,
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 6),
                          // 후기/상담/답변 수
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            children: [
                              Text('시술후기 ${doctor.reviewCount}', style: _statStyle),
                              Text('상담 ${doctor.askCount}', style: _statStyle),
                              if (doctor.qnaAnswerCount > 0)
                                Text('답변 ${doctor.qnaAnswerCount}', style: _statStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final url = 'https://web.babitalk.com/hospitals/$hospitalId?tab=doctor&category_type=SURGERY';
                _openExternalWebView(context, url);
              },
              child: const Text(
                '이벤트 더 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _statStyle => const TextStyle(fontSize: 9, color: Colors.black54);
}

class HospitalYoutubeList extends StatefulWidget {
  final List<Youtube> youtubes;
  final int hospitalId;

  const HospitalYoutubeList({
    super.key,
    required this.youtubes,
    required this.hospitalId,
  });

  @override
  State<HospitalYoutubeList> createState() => _HospitalYoutubeListState();
}

class _HospitalYoutubeListState extends State<HospitalYoutubeList> {
  @override
  Widget build(BuildContext context) {
    if (widget.youtubes.isEmpty) return const SizedBox.shrink(); // ✅ 꼭 widget. 붙이기

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '공식 유튜브',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ...widget.youtubes.map((video) {
          debugPrint('🎥 렌더링 videoId: ${video.videoId}'); // ✅ 다시 찍히는지 확인

          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadHtmlString('''
            <!DOCTYPE html>
            <html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
              </head>
              <body style="margin:0;padding:0;">
                <iframe
                  src="https://www.youtube.com/embed/${video.videoId}?playsinline=1"
                  width="100%" height="100%" frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen>
                </iframe>
              </body>
            </html>
          ''');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(controller: controller),
                ),
                const SizedBox(height: 8),
                Text(
                  video.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class HospitalImageBanner extends StatefulWidget {
  final List<String> images;

  const HospitalImageBanner({super.key, required this.images});

  @override
  State<HospitalImageBanner> createState() => _HospitalImageBannerState();
}

class _HospitalImageBannerState extends State<HospitalImageBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _current = index),
            itemBuilder: (_, i) {
              return CachedNetworkImage( // ✅ 캐싱 적용
                imageUrl: widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_current + 1} / ${widget.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}