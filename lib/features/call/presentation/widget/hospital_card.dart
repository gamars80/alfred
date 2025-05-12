import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../like/data/like_repository.dart';
import '../../model/hostpital.dart';

class HospitalCard extends StatefulWidget {
  final Hospital hospital;
  final int historyCreatedAt;
  final void Function(Hospital updated)? onLikedChanged;

  const HospitalCard({
    Key? key,
    required this.hospital,
    required this.historyCreatedAt,
    this.onLikedChanged,
  }) : super(key: key);

  @override
  State<HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<HospitalCard> {
  late Hospital _hospital;
  final LikeRepository _likeRepo = LikeRepository();

  @override
  void initState() {
    super.initState();
    _hospital = widget.hospital;
  }

  Future<void> _toggleLike() async {
    final isNowLiked = !_hospital.liked;

    setState(() {
      _hospital = _hospital.copyWith(liked: isNowLiked);
    });

    try {
      if (isNowLiked) {
        await _likeRepo.postLikeBeautyHospital(
          historyCreatedAt: widget.historyCreatedAt,
          hospitalId: _hospital.id.toString(),
          source: _hospital.source,
        );
      } else {
        await _likeRepo.deleteLikeBeautyHospital(
          historyCreatedAt: widget.historyCreatedAt,
          hospitalId: _hospital.id.toString(),
          source: _hospital.source,
        );
      }

      widget.onLikedChanged?.call(_hospital);
    } catch (e) {
      setState(() {
        _hospital = _hospital.copyWith(liked: !isNowLiked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/hospital-detail/${_hospital.id}', extra: _hospital);
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: _hospital.thumbnailUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _hospital.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _hospital.liked ? Icons.favorite : Icons.favorite_border,
                        color: _hospital.liked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: _toggleLike,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${_hospital.location} · ${_hospital.hospitalName}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _iconText(Icons.star, '${_hospital.rating}점'),
                    _iconText(Icons.reviews, '${_hospital.ratingCount}건'),
                    _iconText(Icons.event_available, '${_hospital.doctorCount}명의 의사'),
                    _iconText(Icons.question_answer, '${_hospital.counselCount}건 상담'),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _hospital.description
                      .split(RegExp(r'\s+'))
                      .map((word) => Text(
                    word.startsWith('#') ? word : '$word',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ))
                      .toList(),
                ),
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
