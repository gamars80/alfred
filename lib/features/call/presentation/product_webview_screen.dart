import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/common/dio/dio_client.dart'; // DioClient 경로는 프로젝트 구조에 따라 조정

class ProductWebViewScreen extends StatefulWidget {
  final String url;
  final String productId;
  final int historyCreatedAt;
  final String source;

  const ProductWebViewScreen({
    super.key,
    required this.url,
    required this.productId,
    required this.historyCreatedAt,
    required this.source,
  });

  @override
  State<ProductWebViewScreen> createState() => _ProductWebViewScreenState();
}

class _ProductWebViewScreenState extends State<ProductWebViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleOpenFlow();
    });
  }

  Future<void> _handleOpenFlow() async {
    final context = this.context;
    final apiPath =
        '/api/products/${widget.productId}/${widget.historyCreatedAt}/${Uri.encodeComponent(widget.source)}/open';

    try {
      final response = await DioClient.dio.post(apiPath);

      if (response.statusCode == 200) {
        final uri = Uri.parse(widget.url);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          _showSnackBar('브라우저를 열 수 없습니다: ${widget.url}');
        }
      } else {
        _showSnackBar('API 호출 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ProductWebView] API 호출 오류: $e');
      _showSnackBar('API 호출 중 오류가 발생했습니다.');
    } finally {
      Navigator.of(context).pop(); // 무조건 현재 화면 닫음
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
