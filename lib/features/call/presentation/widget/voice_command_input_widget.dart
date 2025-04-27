import 'package:flutter/material.dart';

class VoiceCommandInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final VoidCallback onMicPressed;
  final VoidCallback onSubmit;
  final String category; // 추가된 파라미터

  // const 제거
  VoiceCommandInputWidget({
    Key? key,
    required this.controller,
    required this.isListening,
    required this.isLoading,
    required this.onMicPressed,
    required this.onSubmit,
    this.category = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final promptText = category == '시술커뮤니티'
        ? '어떤 고민이 있으신가요?'
        : '어떤 상품을 찾아드릴까요?';

    final hintText = category == '시술커뮤니티'
        ? '코가 낮아서 이참에 수술을 해볼까 생각중이야'
        : '예: 20대 여자친구에게 선물할 원피스 추천해줘';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            promptText,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
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
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
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
