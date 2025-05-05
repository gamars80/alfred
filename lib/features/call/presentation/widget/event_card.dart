import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  Future<void> _openWebView() async {
    final url = 'https://www.gangnamunni.com/events/${event.id}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(onTap: _openWebView, child: _buildThumbnail()),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.location} · ${event.hospitalName}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildPriceSection(), _buildRatingSection()],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: CachedNetworkImage(
          imageUrl: event.thumbnailUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey[300]),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey[400],
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return Row(
      children: [
        if (event.discountRate > 0)
          Text('${event.discountRate}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
        if (event.discountRate > 0) const SizedBox(width: 4),
        Text('${formatter.format(event.discountedPrice)}원',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(event.rating,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(width: 4),
        Text('(${event.ratingCount})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
