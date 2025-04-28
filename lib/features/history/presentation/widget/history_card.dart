import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/recommendation_history.dart';


class HistoryCard extends StatelessWidget {
  final RecommendationHistory history;
  final List<String> Function(String) extractTags;
  final VoidCallback onTap;

  const HistoryCard({
    Key? key,
    required this.history,
    required this.extractTags,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = extractTags(history.gptCondition);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          color: Colors.white,
          elevation: 6, // 그림자 더 강하게
          shadowColor: Colors.black.withOpacity(0.15), // 그림자 더 진하게
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // 둥글기 더 강조
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.query,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(history.createdAt),
                      ),
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


