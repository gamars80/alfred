import 'package:flutter/material.dart';
import '../model/chat_message.dart';
import '../service/openai_chat_service.dart';
import 'widget/chat_message_widget.dart';
import 'widget/chat_input_widget.dart';
import 'widget/quick_reply_buttons.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage.ai(
        '안녕하세요! 저는 알프레드입니다. 🎉\n\n'
        '음식 추천, 쇼핑 도움, 뷰티 추천, 병원 추천 등\n'
        '무엇이든 도와드릴 수 있어요!\n\n'
        '무엇을 도와드릴까요?',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
            Text(
              '알프레드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(
                  message: message,
                  onProductTap: _handleProductTap,
                );
              },
            ),
          ),
          
          // 빠른 응답 버튼 (첫 메시지 이후에만 표시)
          if (_messages.length > 1)
            QuickReplyButtons(
              onQuickReply: _handleQuickReply,
            ),
          
          // 입력 위젯
          ChatInputWidget(
            controller: _textController,
            isLoading: _isLoading,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = ChatMessage.user(message);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    // AI 응답 요청
    try {
      final aiResponse = await OpenAIChatService.sendMessage(message);
      setState(() {
        _messages.add(aiResponse);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage.ai('죄송합니다. 응답을 생성하는 중 오류가 발생했습니다.'),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _handleQuickReply(String reply) {
    _sendMessage(reply);
  }

  void _handleProductTap(Map<String, dynamic> product) {
    // 상품 상세 페이지로 이동
    debugPrint('상품 탭: $product');
    // TODO: 상품 상세 페이지 구현
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
} 