import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart'; // ✅ 추가
import '../data/auth_api.dart' as my_auth;
import '../model/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // ✅ 로그인 먼저 시도
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('✅ 로그인 성공: ${token.accessToken}');

      // ✅ 로그인 이후 사용자 정보 호출
      final user = await UserApi.instance.me();

      final kakaoId = user.id.toString();
      final email = user.kakaoAccount?.email ?? '';
      final name = user.kakaoAccount?.profile?.nickname ?? '';

      final loginResponse = await my_auth.AuthApi.loginWithKakaoId(kakaoId);

      if (loginResponse.needSignup) {
        final phone = user.kakaoAccount?.phoneNumber ?? '';
        final signupResponse = await my_auth.AuthApi.registerKakaoUser(
          loginId: kakaoId,
          email: email,
          name: name,
          phoneNumber: phone,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', signupResponse.token ?? '');

        context.go('/main');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', loginResponse.token ?? '');

        context.go('/main');
      }
    } catch (e, stack) {
      print('❌ 로그인 오류: $e');
      print('스택: $stack');
      _showError(context, '로그인에 실패했습니다');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ 카카오 토큰 존재 여부 확인
      final hasToken = await AuthApi.instance.hasToken();
      if (hasToken) {
        await UserApi.instance.logout();
        print('카카오 로그아웃 완료 ✅');
      } else {
        print('카카오 SDK 토큰 없음 → logout() 생략');
      }

      // ✅ SharedPreferences 토큰 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 되었습니다')),
      );

      if (context.mounted) {
        context.go('/login');
      }
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
