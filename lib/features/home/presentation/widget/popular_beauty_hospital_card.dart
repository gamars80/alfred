import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../call/model/hostpital.dart';
import '../../model/popular_beauty_hospital.dart';

class PopularBeautyHospitalCard extends StatelessWidget {
  final PopularBeautyHospital hospital;
  final int rank;

  const PopularBeautyHospitalCard({
    Key? key,
    required this.hospital,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 240,
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
              // LikedBeautyHospital을 Hospital 모델로 매핑하여 상세 라우트로 전달
              final hospitalModel = Hospital(
                id: hospital.hospitalId,
                source: hospital.source,
                thumbnailUrl: hospital.thumbnailUrl,
                location: hospital.location,
                hospitalName: hospital.hospitalName,
                rating: hospital.rating,
                ratingCount: hospital.ratingCount,
                description: hospital.description,
                counselCount: hospital.counselCount,
                doctorCount: hospital.doctorCount, title: hospital.title, liked: false,
              );
              context.push('/hospital-detail/${hospital.hospitalId}/${hospital.historyAddedAt}', extra: hospitalModel);
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: hospital.thumbnailUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 120, color: Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(height: 120, color: Colors.grey),
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hospital.source,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hospital.location} · ${hospital.hospitalName}',
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _iconText(Icons.star, '${hospital.rating}점'),
                    _iconText(Icons.reviews, '${hospital.ratingCount}건'),
                    _iconText(Icons.person, '${hospital.doctorCount}명의 의사'),
                    _iconText(Icons.question_answer, '${hospital.counselCount}건 상담'),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: hospital.description
                      .split(RegExp(r'[\/\,\s]+'))
                      .map((word) => Text(
                    '#$word',
                    style: const TextStyle(
                      fontSize: 9,
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
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.black87)),
      ],
    );
  }
}
