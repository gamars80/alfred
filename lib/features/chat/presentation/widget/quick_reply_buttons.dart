import 'package:flutter/material.dart';

class QuickReplyButtons extends StatelessWidget {
  final Function(String) onQuickReply;

  const QuickReplyButtons({
    super.key,
    required this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    final quickReplies = [
      '음식 추천해줘',
      '쇼핑 도와줘',
      '뷰티 추천해줘',
      '병원 추천해줘',
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: quickReplies.map((reply) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  reply,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.deepPurple[50],
                side: BorderSide(color: Colors.deepPurple[200]!),
                onPressed: () => onQuickReply(reply),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
} 