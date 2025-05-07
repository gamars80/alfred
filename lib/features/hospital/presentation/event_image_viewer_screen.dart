import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImageWebViewScreen extends StatefulWidget {
  final String imageUrl;

  const ImageWebViewScreen({super.key, required this.imageUrl});

  @override
  State<ImageWebViewScreen> createState() => _ImageWebViewScreenState();
}

class _ImageWebViewScreenState extends State<ImageWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtml(widget.imageUrl));
  }

  String _buildHtml(String url) {
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
      <img src="$url" alt="이벤트 이미지" />
    </body>
    </html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상세',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
