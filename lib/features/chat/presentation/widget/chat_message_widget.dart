import 'package:flutter/material.dart';
import '../../model/chat_message.dart';
import 'ai_message_card.dart';
import 'user_message_card.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(Map<String, dynamic>)? onProductTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.user:
        return UserMessageCard(message: message);
      case MessageType.ai:
        return AiMessageCard(
          message: message,
          onProductTap: onProductTap,
        );
      case MessageType.system:
        return _buildSystemMessage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.content,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 