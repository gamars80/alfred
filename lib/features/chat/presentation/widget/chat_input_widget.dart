import 'package:flutter/material.dart';

/// 채팅 입력 위젯
/// 
/// 사용자가 텍스트를 입력하고 전송할 수 있는 위젯입니다.
/// 실무 수준의 디자인과 다양한 입력 상태를 지원합니다.
class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSendMessage;
  final String? hintText;
  final int? maxLines;
  final bool enableSendButton;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
    this.hintText,
    this.maxLines,
    this.enableSendButton = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSendMessage() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading && widget.enableSendButton) {
      widget.onSendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isFocused ? Colors.deepPurple.withOpacity(0.3) : Colors.grey[200]!,
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused ? [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isLoading,
                maxLines: widget.maxLines ?? 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '메시지를 입력하세요...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    if (widget.isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          onPressed: _hasText && widget.enableSendButton ? _handleSendMessage : null,
          icon: Icon(
            _hasText ? Icons.send_rounded : Icons.send_outlined,
            color: _hasText ? Colors.deepPurple : Colors.grey[400],
            size: 24,
          ),
          style: IconButton.styleFrom(
            backgroundColor: _hasText 
              ? Colors.deepPurple.withOpacity(0.1)
              : Colors.transparent,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }
} 