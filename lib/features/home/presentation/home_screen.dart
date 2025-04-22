// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'popular_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('홈'),
        centerTitle: true,
        // backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            PopularSection(),
            // 앞으로 추가할 섹션: 오늘의 추천, 히스토리, 챌린지 등
          ],
        ),
      ),
    );
  }
}
