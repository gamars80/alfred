import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred_clean/features/like/data/like_repository.dart';
import 'package:alfred_clean/features/like/model/liked_beauty_hospital.dart';
import 'package:alfred_clean/features/call/model/hostpital.dart';

class LikeBeautyHospitalCard extends StatefulWidget {
  final LikedBeautyHospital hospital;
  final void Function(int hospitalId)? onUnlike;

  const LikeBeautyHospitalCard({
    Key? key,
    required this.hospital,
    this.onUnlike,
  }) : super(key: key);


  @override
  State<LikeBeautyHospitalCard> createState() => _LikeBeautyHospitalCardState();
}

class _LikeBeautyHospitalCardState extends State<LikeBeautyHospitalCard> {
  late LikedBeautyHospital _h;
  final LikeRepository _repo = LikeRepository();

  @override
  void initState() {
    super.initState();
    _h = widget.hospital;
  }

  Future<void> _toggleLike() async {
    final historyCreatedAt = int.tryParse(_h.historyAddedAt) ?? 0;
    try {
      await _repo.deleteLikeBeautyHospital(
        historyCreatedAt: historyCreatedAt,
        hospitalId: _h.hospitalId.toString(),
        source: _h.source,
      );
      widget.onUnlike?.call(_h.hospitalId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 취소 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? thumbnail = (_h.thumbnailUrls?.isNotEmpty == true)
        ? _h.thumbnailUrls!.first
        : null;
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumbnail != null)
            GestureDetector(
              onTap: () {
                // LikedBeautyHospital을 Hospital 모델로 매핑하여 상세 라우트로 전달
                final hospitalModel = Hospital(
                  id: _h.hospitalId,
                  source: _h.source,
                  thumbnailUrl: thumbnail,
                  location: _h.location,
                  hospitalName: _h.hospitalName,
                  rating: _h.rating,
                  ratingCount: _h.ratingCount,
                  description: _h.description,
                  counselCount: _h.counselCount,
                  doctorCount: _h.doctorCount, title: _h.title, liked: false,
                );
                context.push('/hospital-detail/${_h.hospitalId}/${_h.historyAddedAt}', extra: hospitalModel);
              },
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _h.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: _toggleLike,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_h.location} · ${_h.hospitalName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _iconText(Icons.star, '${_h.rating}'),
                    _iconText(Icons.reviews, '${_h.ratingCount}'),
                    _iconText(Icons.event_available,
                        '${_h.doctorCount}명 의사'),
                    _iconText(Icons.question_answer,
                        '${_h.counselCount}건 상담'),
                  ],
                ),
                if (_h.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _h.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.deepPurple),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ],
    );
  }
}
