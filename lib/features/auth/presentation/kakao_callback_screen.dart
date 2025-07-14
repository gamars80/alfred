import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:alfred_clean/features/auth/data/auth_api.dart' as my_auth;
import 'package:shared_preferences/shared_preferences.dart';

class KakaoCallbackScreen extends StatefulWidget {
  final String? code;
  const KakaoCallbackScreen({Key? key, required this.code}) : super(key: key);

  @override
  State<KakaoCallbackScreen> createState() => _KakaoCallbackScreenState();
}

class _KakaoCallbackScreenState extends State<KakaoCallbackScreen> {
  bool _handled = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handled && widget.code != null) {
      _handled = true;
      _handleKakaoCode(widget.code!);
    }
  }

  Future<void> _handleKakaoCode(String code) async {
    try {
      // code_verifier는 로그인 버튼 누를 때 생성해서 전달받아야 함 (여기선 예시)
      // 실제 앱에서는 안전하게 전달/보관 필요
      final codeVerifier = null; // TODO: 안전하게 전달받기
      if (codeVerifier == null) {
        setState(() { _errorMessage = 'code_verifier가 없습니다. 다시 시도해 주세요.'; });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/login');
        return;
      }
      final token = await AuthApi.instance.issueAccessToken(
        authCode: code,
        codeVerifier: codeVerifier,
        redirectUri: 'kakao22e6b88148da0c4cb1293cbe664cecc4://oauth',
      );
      await TokenManagerProvider.instance.manager.setToken(token);
      final user = await UserApi.instance.me();
      final loginId = user.id.toString();
      final email = user.kakaoAccount?.email ?? '';
      final name = user.kakaoAccount?.profile?.nickname ?? '';
      final phoneNumber = user.kakaoAccount?.phoneNumber ?? '';
      // 백엔드 로그인
      final loginResp = await my_auth.AuthApi.loginWithKakaoId(loginId);
      if (loginResp.token == null || loginResp.token!.isEmpty) {
        setState(() { _errorMessage = '백엔드 로그인 실패'; });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/login');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', loginResp.token!);
      if (mounted) context.go('/main');
    } catch (e) {
      setState(() { _errorMessage = '카카오 로그인 실패: $e'; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _errorMessage == null
            ? const CircularProgressIndicator()
            : Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
} 