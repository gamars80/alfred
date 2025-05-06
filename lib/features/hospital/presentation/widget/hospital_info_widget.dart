
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HospitalInfoCard extends StatelessWidget {
  final String name;
  final String region;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const HospitalInfoCard({
    super.key,
    required this.name,
    required this.region,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            region,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '$rating',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text('($reviewCount)', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: tags
                .map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.deepPurple.shade50,
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 11, color: Colors.deepPurple),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
