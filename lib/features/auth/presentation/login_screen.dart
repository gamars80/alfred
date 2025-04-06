import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart'; // ✅ 추가
import '../data/auth_api.dart' as my_auth;
import '../model/login_response.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      final user = await UserApi.instance.me();
      final kakaoId = user.id.toString();

      final loginResponse = await my_auth.AuthApi.loginWithKakaoId(kakaoId);

      if (loginResponse.needSignup) {
        // 회원가입 화면으로 이동
        print('❌ 회원 가입이 필요합니다');
        // context.go('/signup');
      } else if (loginResponse.token != null) {
        // 로그인 성공 → 홈 화면 이동
        print('✅ 로그인 성공. 토큰: ${loginResponse.token}');
        context.go('/main');
      } else {
        _showError(context, loginResponse.message ?? '알 수 없는 오류');
      }
    } catch (e, stack) {
      print('❌ 로그인 오류: $e');
      print('스택: $stack');
      _showError(context, '서버와 통신에 실패했습니다');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await UserApi.instance.logout();
      await UserApi.instance.unlink();
      print('카카오 로그아웃 완료 ✅');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 되었습니다')),
      );
    } catch (e) {
      print('로그아웃 실패 ❌: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/butler_logo.png'),
              const SizedBox(height: 12),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _loginWithKakao(context),
                child: Image.asset(
                  'assets/images/kakao_login_button.png',
                  width: double.infinity,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('애플 로그인'),
              ),
              const SizedBox(height: 32),

              /// 👉 테스트용 로그아웃 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _logout(context),
                child: const Text('카카오 로그아웃 (테스트용)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
