import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductWebViewScreen extends StatelessWidget {
  final String url;

  const ProductWebViewScreen({super.key, required this.url});

  // 모든 URL을 외부 브라우저에서 열기
  Future<void> _openInExternalBrowser(BuildContext context) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('브라우저를 열 수 없습니다: $url')),
        );
      }
    } catch (e) {
      debugPrint("외부 브라우저 열기 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('브라우저 열기 중 오류가 발생했습니다.')),
      );
    }

    // 호출 후 현재 화면 닫기
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 열리자마자 외부 브라우저 열기 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInExternalBrowser(context);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
