import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/presentation/webview_screen.dart';
import '../../model/hospital_detail_model.dart';

class HospitalImageCarousel extends StatelessWidget {
  final List<String> images;

  const HospitalImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover),
      ),
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
  
  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '이벤트',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...events.map((event) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                            ? Image.network(event.bannerImage!, height: 80, fit: BoxFit.cover)
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
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // 💜 보라 계열
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

  const HospitalReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews.map((review) {
        return ListTile(
          title: Text('${review.rating}점 후기'),
          subtitle: Text(review.text, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }
}

class HospitalDoctorInfo extends StatelessWidget {
  final List<Doctor> doctors;

  const HospitalDoctorInfo({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctors.map((doctor) {
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(doctor.profilePhoto)),
          title: Text(doctor.name),
          subtitle: Text(doctor.specialist ?? '전문의 정보 없음'),
        );
      }).toList(),
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
              return Image.network(
                widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
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