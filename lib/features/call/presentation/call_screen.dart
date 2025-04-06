import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final TextEditingController _textController = TextEditingController();
  int _selectedReviewIndex = -1;
  String? _webUrl;
  WebViewController? _webViewController;

  void _showReviews(int index) {
    setState(() {
      _selectedReviewIndex = _selectedReviewIndex == index ? -1 : index;
    });
  }

  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('상품 상세'),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
          ),
        ),
      ),
    );
  }

  void _closeWebView() {
    setState(() {
      _webUrl = null;
      _webViewController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('집사호출')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: '텍스트를 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // 명령 로직 구현 예정
                      },
                      child: const Text('명령하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.network(
                                  'https://picsum.photos/id/${index + 10}/50/50',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                '이것은 매우 긴 추천 상품 이름 ${index + 1}입니다',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('₩99,000', style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _showReviews(index),
                                    child: const Text(
                                      '리뷰 123개 보기',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () => _openWebView('https://shop.coupang.com/pulmuonefood/314728?source=brandstore_display_ads&adType=DA&eventId=8zlP4HFwQh9LU1Tj&from=home_C2&traid=home_C2&trcid=11519123&platform=p'),
                            ),
                            if (_selectedReviewIndex == index)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Column(
                                  children: List.generate(2, (reviewIndex) {
                                    final hasImage = reviewIndex % 2 == 0;
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: hasImage
                                          ? Image.network(
                                        'https://picsum.photos/seed/review$reviewIndex/40/40',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                          : null,
                                      title: const Text('⭐️⭐️⭐️⭐️☆', style: TextStyle(color: Colors.white)),
                                      subtitle: const Text(
                                        '정말 좋았어요! 상품 품질이 우수하고 배송도 빨랐습니다.',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_webUrl != null && _webViewController != null)
            Positioned.fill(
              child: Material(
                color: Colors.black,
                child: Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.black,
                      title: const Text('상품 상세'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _closeWebView,
                        ),
                      ],
                    ),
                    Expanded(
                      child: WebViewWidget(controller: _webViewController!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
