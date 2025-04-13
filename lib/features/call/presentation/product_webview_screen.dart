import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductWebViewScreen extends StatelessWidget {
  final String url;

  const ProductWebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 상세보기')),
      body: SafeArea(
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(url)),
        ),
      ),
    );
  }
}
