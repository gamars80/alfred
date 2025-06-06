import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('명령권 내역', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            onTap: () {
              context.push('/mypage/command-authority-history');
            },
          ),
          const Divider(height: 1, color: Colors.black12),
          ListTile(
            title: const Text('설정', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            onTap: () {
              context.push('/mypage/settings');
            },
          ),
          const Divider(height: 1, color: Colors.black12),
        ],
      ),
    );
  }
} 