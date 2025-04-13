import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_webview_screen.dart'; // ✅ import
import '../data/product_api.dart';
import '../model/product.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final TextEditingController _commandController = TextEditingController();
  bool _showOverlay = false;
  bool _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('상품 추천'),
            backgroundColor: Colors.black,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categorizedProducts.isEmpty
              ? const Center(
              child: Text('추천된 상품이 없습니다.',
                  style: TextStyle(color: Colors.white)))
              : ListView(
            padding: const EdgeInsets.all(12),
            children: _categorizedProducts.entries.map((entry) {
              final category = entry.key;
              final products = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
          ),
        ),
        if (_showOverlay) _buildOverlayLayer(context),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
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
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.mallName.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.mallName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    '₩ ${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                  if (product.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(product.reason,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayLayer(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showOverlay = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('어떤 상품을 찾아드릴까요?',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: '예: 여름에 어울리는 선물',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
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
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('명령하기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
