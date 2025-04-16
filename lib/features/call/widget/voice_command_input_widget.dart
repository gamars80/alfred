import 'package:flutter/material.dart';

class VoiceCommandInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final VoidCallback onMicPressed;
  final VoidCallback onSubmit;

  const VoiceCommandInputWidget({
    super.key,
    required this.controller,
    required this.isListening,
    required this.isLoading,
    required this.onMicPressed,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '어떤 상품을 찾아드릴까요?',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        const SizedBox(height: 16),

        // 텍스트 입력창
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: '예: 여름에 어울리는 선물',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        const SizedBox(height: 12),

        // 마이크 버튼 및 상태
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onMicPressed,
              icon: Icon(
                Icons.mic,
                color: isListening ? Colors.red : Colors.deepPurple,
              ),
              label: Text(
                isListening ? '듣는 중...' : '음성 인식',
                style: TextStyle(
                  color: isListening ? Colors.red : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 명령하기 버튼
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('명령하기'),
        ),
      ],
    );
  }
}
