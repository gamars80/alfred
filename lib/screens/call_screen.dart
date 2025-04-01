import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('집사호출')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                  onPressed: () {},
                  child: const Text('명령하기'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: List.generate(3, (index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network('https://via.placeholder.com/50', fit: BoxFit.cover),
                      ),
                      title: Text('추천 상품 ${index + 1}'),
                      subtitle: const Text('₩99,000 - 리뷰 123개'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}