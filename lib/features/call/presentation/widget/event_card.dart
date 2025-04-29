import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8), // ✅ 밝은 카드 배경
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: event.thumbnailUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 160,
                color: Colors.grey[300], // 로딩 중 회색 박스
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 160,
                color: Colors.grey[400],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13, // ✅ 제목 크기 축소
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${event.location} · ${event.hospitalName}',
                  style: const TextStyle(
                    fontSize: 11, // ✅ 위치/병원도 축소
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (event.discountRate > 0)
                      Text(
                        '${event.discountRate}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    if (event.discountRate > 0)
                      const SizedBox(width: 4),
                    Text(
                      '${formatter.format(event.discountedPrice)}원',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}


