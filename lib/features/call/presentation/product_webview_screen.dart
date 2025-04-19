import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductWebViewScreen extends StatelessWidget {
  final String url;

  const ProductWebViewScreen({super.key, required this.url});

  bool _isNaverUrl(String url) {
    return Uri.parse(url).host.contains('naver.com');
  }

  Future<void> _openExternalBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isNaverUrl(url)) {
      // 네이버 URL인 경우 외부 브라우저로 오픈
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openExternalBrowser(url);
        Navigator.of(context).pop();
      });

      // 외부 브라우저 열기 중 로딩 표시
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 일반 URL인 경우 WebView로 표시
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: const Text('상품 상세보기')),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
