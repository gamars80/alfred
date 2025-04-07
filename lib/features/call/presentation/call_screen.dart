import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/product_api.dart';
import '../model/product.dart';
import '../../../common/utils/toast_util.dart';
import '../logic/call_validator.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final TextEditingController _commandController = TextEditingController();
  bool _showOverlay = false;
  bool _isLoading = false;
  List<Product> _products = [];

  Future<void> _fetchProducts(String query) async {
    setState(() => _isLoading = true);
    try {
      final api = ProductApi();
      final products = await api.fetchRecommendedProducts(query);
      setState(() {
        _products = products;
        _showOverlay = false;
      });
    } catch (e) {
      debugPrint('API 호출 실패: $e');
    }
    setState(() => _isLoading = false);
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('상품 추천')),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? const Center(child: Text('추천된 상품이 없습니다.'))
              : Padding(
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${product.price}원', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(product.reason, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () => _launchUrl(product.link),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _toggleOverlay,
            label: const Text('알프레드~'),
            icon: const Icon(Icons.mic),
          ),
        ),
        if (_showOverlay) _buildOverlayLayer(context),
      ],
    );
  }

  Widget _buildOverlayLayer(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showOverlay = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 320),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '알프레드에게 명령하세요',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _commandController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: '예: 여름 등산 장비 추천해줘',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final query = _commandController.text;
                            final error = CallValidator.validateQuery(query);
                            if (error != null) {
                              ToastUtil.showOverlay(context, error); // ✅ 오버레이 토스트 사용
                              return;
                            }
                            _fetchProducts(query);
                          },
                          child: const Text('명령하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) {
    debugPrint('Open URL: $url');
  }
}