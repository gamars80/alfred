import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductWebViewScreen extends StatelessWidget {
  final String url;

  const ProductWebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
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
