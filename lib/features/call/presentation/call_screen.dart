import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../data/product_api.dart';
import '../model/product.dart';
import 'product_webview_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const platform = MethodChannel('com.alfred/voice');

  final TextEditingController _commandController = TextEditingController();
  bool _showOverlay = false;
  bool _isLoading = false;
  bool _isListening = false;
  Map<String, List<Product>> _categorizedProducts = {};
  final currencyFormatter = NumberFormat('#,###', 'ko_KR');

  Future<void> _fetchProducts(String query) async {
    setState(() => _isLoading = true);
    try {
      final api = ProductApi();
      final result = await api.fetchRecommendedProducts(query);
      setState(() {
        _categorizedProducts = result;
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

  Future<void> _startNativeListening() async {
    setState(() => _isListening = true);
    try {
      final result = await platform.invokeMethod<String>('startListening');
      if (result != null && result.isNotEmpty) {
        setState(() {
          _commandController.text = result;
        });
      }
    } on PlatformException catch (e) {
      debugPrint("음성 인식 오류: ${e.message}");
    }
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('상품 추천', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categorizedProducts.isEmpty
              ? const Center(
              child: Text('추천된 상품이 없습니다.',
                  style: TextStyle(color: Colors.grey)))
              : ListView(
            padding: const EdgeInsets.all(16),
            children: _categorizedProducts.entries.map((entry) {
              final category = entry.key;
              final products = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  ...products
                      .map((product) => _buildProductCard(product))
                      .toList(),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _toggleOverlay,
            label: const Text('알프레드~'),
            icon: const Icon(Icons.mic),
            backgroundColor: Colors.deepPurple,
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
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('어떤 상품을 찾아드릴까요?',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commandController,
                          style: const TextStyle(color: Colors.black),
                          minLines: 2,
                          maxLines: 5,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: '예: 여름에 어울리는 선물',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: _isListening ? Colors.red : Colors.deepPurple,
                        ),
                        onPressed: _startNativeListening,
                      ),
                      if (_isListening)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            '듣는 중...',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final query = _commandController.text.trim();
                      if (query.isNotEmpty) {
                        _fetchProducts(query);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('검색어를 입력해주세요.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('명령하기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductWebViewScreen(url: product.link),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.mallName.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.mallName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₩ ${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  if (product.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        product.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
