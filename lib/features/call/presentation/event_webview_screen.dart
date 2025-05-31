import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventWebViewScreen extends StatefulWidget {
  final String url;

  const EventWebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<EventWebViewScreen> createState() => _EventWebViewScreenState();
}

class _EventWebViewScreenState extends State<EventWebViewScreen> {
  @override
  void initState() {
    super.initState();
    _launchWebView();
  }

  Future<void> _launchWebView() async {
    final uri = Uri.parse(widget.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('브라우저를 열 수 없습니다.')),
      );
    }

    // 🔽 딜레이 추가
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pop(); // 성공 여부 관계없이 이 화면은 종료
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
