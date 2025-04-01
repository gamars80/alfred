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

      // 사용자 정보 요청
      User user = await UserApi.instance.me();
      print('사용자 정보: ${user.kakaoAccount?.profile?.nickname}');

      // 로그인 성공 시 다음 화면으로 이동
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      print('카카오 로그인 실패 ❌ : $e');
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
              Image.asset(
                'assets/images/butler_logo.png',
                // width: 100,
                // height: 100,
              ),
              const SizedBox(height: 12),
              // const Text(
              //   '알프레드',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
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
            ],
          ),
        ),
      ),
    );
  }
}
