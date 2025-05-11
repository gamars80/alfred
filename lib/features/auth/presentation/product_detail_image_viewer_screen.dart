import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductDetailImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;

  const ProductDetailImageViewerScreen({super.key, required this.imageUrls});

  @override
  State<ProductDetailImageViewerScreen> createState() => _ProductDetailImageViewerScreenState();
}

class _ProductDetailImageViewerScreenState extends State<ProductDetailImageViewerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtml(widget.imageUrls));
  }

  String _buildHtml(List<String> urls) {
    final imagesHtml = urls.map((url) => '<img src="$url" alt="이미지" />').join('\n');

    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          margin: 0;
          background-color: black;
        }
        img {
          width: 100%;
          height: auto;
          display: block;
        }
      </style>
    </head>
    <body>
      $imagesHtml
    </body>
    </html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 이미지',style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
