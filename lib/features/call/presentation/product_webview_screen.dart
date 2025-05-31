import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/common/dio/dio_client.dart';

class ProductWebViewScreen extends StatefulWidget {
  final String url;
  final String productId;
  final int historyId;
  final String source;

  const ProductWebViewScreen({
    super.key,
    required this.url,
    required this.productId,
    required this.historyId,
    required this.source,
  });

  @override
  State<ProductWebViewScreen> createState() => _ProductWebViewScreenState();
}

class _ProductWebViewScreenState extends State<ProductWebViewScreen> {
  @override
  void initState() {
    super.initState();
    _handleOpenFlow();
  }

  Future<void> _handleOpenFlow() async {
    try {
      final apiPath =
          '/api/products/${widget.productId}/${widget.historyId}/${Uri.encodeComponent(widget.source)}/open';


      final response = await DioClient.dio.post(apiPath);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final uri = Uri.parse(widget.url);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('브라우저를 열 수 없습니다.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API 호출 실패: 상태 코드 ${response.statusCode}')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('[ProductWebView] API 호출 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API 호출 중 오류가 발생했습니다.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
