import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/beauty_history.dart';

class BeautyHistoryCard extends StatelessWidget {
  final BeautyHistory history;
  final VoidCallback onTap;

  const BeautyHistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(history.createdAt),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#${history.keyword}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  history.query,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
