import 'package:flutter/material.dart';

class VoiceCommandInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final VoidCallback onMicPressed;
  final VoidCallback onSubmit;
  final String category;

  const VoiceCommandInputWidget({
    Key? key,
    required this.controller,
    required this.isListening,
    required this.isLoading,
    required this.onMicPressed,
    required this.onSubmit,
    this.category = '',
  }) : super(key: key);

  @override
  State<VoiceCommandInputWidget> createState() => _VoiceCommandInputWidgetState();
}

class _VoiceCommandInputWidgetState extends State<VoiceCommandInputWidget> {
  @override
  Widget build(BuildContext context) {
    final promptText = widget.category == '시술/성형'
        ? '어떤 고민이 있으신가요?'
        : widget.category == '음식/식자재'
            ? '먹고 싶은 것을 말씀하세요'
            : widget.category == '뷰티케어'
                ? '고민을 말해보세요'
                : '어떤 상품을 찾아드릴까요?';

    final hintText = widget.category == '시술/성형'
        ? '코가 낮아서 이참에 수술을 해볼까 생각중이야'
        : widget.category == '음식/식자재'
            ? '김치찌개가 먹고싶어'
            : widget.category == '뷰티케어'
                ? '요즘 머리가 너무 가려워'
                : '예: 20대 여자친구에게 선물할 원피스 추천해줘';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promptText, style: const TextStyle(color: Colors.black, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              style: const TextStyle(color: Colors.black),
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: widget.isListening ? null : widget.onMicPressed,
                  icon: Icon(Icons.mic, color: widget.isListening ? Colors.red : Colors.deepPurple),
                  label: Row(
                    children: [
                      Text(
                        widget.isListening ? '듣는 중...' : '음성 인식',
                        style: TextStyle(
                          color: widget.isListening ? Colors.red : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isListening) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('명령하기'),
            ),
          ],
        ),
      ),
    );
  }
}
