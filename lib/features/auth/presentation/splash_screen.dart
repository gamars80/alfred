import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        context.go('/main'); // 자동 로그인
      } else {
        context.go('/login'); // 로그인 필요
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '🔐 Alfred 로딩 중...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
