import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('🎬 Splash Screen - initState called');
    
    // 페이드 인 애니메이션 설정
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 페이드 시간 2초로 증가
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // 첫 프레임이 렌더링된 후에 로그인 체크를 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎬 Splash Screen - First frame rendered');
      _startSplashSequence();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startSplashSequence() async {
    try {
      // 1. 먼저 페이드 인 시작
      await _fadeController.forward();
      
      // 2. 토큰 체크는 별도로 미리 시작
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      
      // 3. 충분한 표시 시간 보장
      print('🎬 Splash Screen - Starting delay');
      await Future.delayed(const Duration(seconds: 3)); // 전체 표시 시간 3초로 변경
      print('🎬 Splash Screen - Delay completed');

      if (!mounted) return;
      
      print('🔐 Splash Screen - Token check: ${token != null ? "Token exists" : "No token"}');
      print('🔐 Token value: ${token?.substring(0, 20) ?? "null"}...');

      // 4. 페이드 아웃
      await _fadeController.reverse();

      // 5. 네비게이션
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        print('🔐 Navigating to /main');
        context.go('/main');
      } else {
        print('🔐 Navigating to /login');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Error in splash sequence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎬 Splash Screen - build called');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand( // SizedBox.expand를 사용하여 전체 화면 크기 확보
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: ConstrainedBox( // ConstrainedBox를 사용하여 크기 제한
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Column이 필요한 만큼만 공간 차지
                children: const [
                  Text(
                    '알프레드',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 46,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ALFRED',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 6,
                    ),
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
