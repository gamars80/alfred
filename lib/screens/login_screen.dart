import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('로그인 성공 ✅ : ${token.accessToken}');

      User user = await UserApi.instance.me();
      print('사용자 전체 정보: ${user.toJson()}');

      Navigator.pushReplacementNamed(context, '/main');
    } catch (e, stack) {
      print('카카오 로그인 실패 ❌ : $e');
      print('스택트레이스: $stack');
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _loginWithKakao(context),
                child: const Text('카카오 로그인'),
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
}
