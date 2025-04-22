import 'package:alfred_clean/features/auth/presentation/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../data/auth_api.dart' as my_auth;
import '../model/login_response.dart';
import '../model/signup_response.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  /// Navigate to WebView with url and title
  void _openWebView(BuildContext context, String url, String title) {
    final uriString = Uri(
      path: '/webview',
      queryParameters: {'url': url, 'title': title},
    ).toString();
    context.push(uriString);
  }

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // 실제 연동 시 주석 해제
      /*
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      final user = await UserApi.instance.me();
      final loginId = user.id.toString();
      final email = user.kakaoAccount?.email ?? '';
      final name = user.kakaoAccount?.profile?.nickname ?? '';
      final phoneNumber = user.kakaoAccount?.phoneNumber ?? '';
      */
      const loginId = '4008586108';
      const email = '';
      const name = '';
      const phoneNumber = '';

      // 1) 토큰 여부 확인용 로그인 호출
      final loginResp = await my_auth.AuthApi.loginWithKakaoId(loginId);

      if (loginResp.needSignup) {
        // 2) 신규 회원: 약관 동의 모달
        final agreed = await _showAgreementBottomSheet(context);
        if (!agreed) return;

        // 3) 회원가입 API 호출
        final signupResp = await my_auth.AuthApi.registerKakaoUser(
          loginId: loginId,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );
        // 4) 토큰 저장 및 집사호출 메뉴로 이동
        await _saveTokenAndNavigate(context, signupResp.token, route: '/main');
      } else {
        // 기존 회원: 바로 토큰 저장 및 메인으로 이동
        await _saveTokenAndNavigate(context, loginResp.token, route: '/main');
      }
    } catch (e) {
      _showError(context, '로그인에 실패했습니다');
    }
  }

  Future<void> _saveTokenAndNavigate(
      BuildContext context,
      String? token, {
        required String route,
      }) async {
    if (token == null || token.isEmpty) {
      _showError(context, '유효하지 않은 토큰입니다');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    context.go(route);
  }

  Future<bool> _showAgreementBottomSheet(BuildContext context) {
    const tosUrl = 'https://halved-molybdenum-484.notion.site/1dbf9670410180b2a3f7ca3670ddb26d?pvs=4';
    const privacyUrl = 'https://halved-molybdenum-484.notion.site/1dbf9670410180c0b7c6f9baf0204286?pvs=4';

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        bool agreeTos = true;
        bool agreePrivacy = true;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('약관 동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: agreeTos,
                      onChanged: (v) => setState(() => agreeTos = v!),
                      title: GestureDetector(
                        onTap: () => _openWebView(context, tosUrl, '이용약관'),
                        child: const Text('이용약관 (필수)', style: TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),
                    CheckboxListTile(
                      value: agreePrivacy,
                      onChanged: (v) => setState(() => agreePrivacy = v!),
                      title: GestureDetector(
                        onTap: () => _openWebView(context, privacyUrl, '개인정보처리 취급방침'),
                        child: const Text('개인정보처리 취급방침 (필수)', style: TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!agreeTos) {
                          Fluttertoast.showToast(msg: '이용약관에 동의해주세요');
                          return;
                        }
                        if (!agreePrivacy) {
                          Fluttertoast.showToast(msg: '개인정보처리 취급방침에 동의해주세요');
                          return;
                        }
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('동의 및 계속'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그아웃 되었습니다')));
    context.go('/login');
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
                onPressed: () => context.go('/main'),
                child: const Text('애플 로그인'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
