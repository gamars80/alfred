import 'package:alfred_clean/features/auth/presentation/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_api.dart' as my_auth;
import '../model/login_response.dart';
import '../model/signup_response.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  /// Navigate to WebView with url and title
  void _openWebView(BuildContext context, String url, String title) {
    debugPrint('url:::::::::::::::::::$url');
    final uriString = Uri(
      path: '/webview',
      queryParameters: {'url': url, 'title': title},
    ).toString();
    context.push(uriString);
  }

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // 실제 연동 시 주석 해제

      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      final user = await UserApi.instance.me();
      final loginId = user.id.toString();
      final email = user.kakaoAccount?.email ?? '';
      final name = user.kakaoAccount?.profile?.nickname ?? '';
      final phoneNumber = user.kakaoAccount?.phoneNumber ?? '';

      // const loginId = '4008586108';
      // const email = '';
      // const name = '';
      // const phoneNumber = '';

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
      backgroundColor: const Color(0xFF0A0A0A), // Deep black
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Alfred butler logo section - bigger and brighter
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2A2A2A),
                            const Color(0xFF1A1A1A),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.6), // Brighter gold
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 50,
                            spreadRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 30,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(90, 90),
                          painter: ButlerLogoPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // App name in Korean with gold gradient - more elegant font
                    Stack(
                      children: [
                        // Shadow layer for depth
                        Text(
                          '알프레드',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        // Main text with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              const Color(0xFFF4E4C1), // Light gold
                              const Color(0xFFD4AF37), // Gold
                              const Color(0xFFF4E4C1), // Light gold
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            '알프레드',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Subtitle with custom styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'ALFRED',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Personal Style Butler',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Original Kakao login button
                    GestureDetector(
                      onTap: () => _loginWithKakao(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFEE500).withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/kakao_login_button.png',
                            width: double.infinity,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ID/Password login button
                    TextButton(
                      onPressed: () => context.push('/id-password-login'),
                      child: Text(
                        '아이디/비밀번호로 로그인',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Privacy notice with gold accent
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: const Color(0xFFD4AF37).withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '로그인 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// Custom painter for Alfred butler logo - make it more prominent
class ButlerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Add glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.5,
      glowPaint,
    );
    
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37) // Gold color
      ..style = PaintingStyle.fill;
    
    final brightGoldPaint = Paint()
      ..color = const Color(0xFFF4E4C1) // Brighter gold
      ..style = PaintingStyle.fill;
    
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    
    final outlinePaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw bow tie with gradient effect
    final bowTiePath = Path();
    bowTiePath.moveTo(size.width * 0.3, size.height * 0.25);
    bowTiePath.lineTo(size.width * 0.5, size.height * 0.35);
    bowTiePath.lineTo(size.width * 0.7, size.height * 0.25);
    bowTiePath.lineTo(size.width * 0.7, size.height * 0.15);
    bowTiePath.lineTo(size.width * 0.5, size.height * 0.25);
    bowTiePath.lineTo(size.width * 0.3, size.height * 0.15);
    bowTiePath.close();
    
    // Draw bow tie with gradient
    canvas.drawPath(bowTiePath, goldPaint);
    
    // Add highlight to bow tie
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.5, size.height * 0.25);
    highlightPath.lineTo(size.width * 0.7, size.height * 0.15);
    highlightPath.lineTo(size.width * 0.65, size.height * 0.2);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.28);
    highlightPath.close();
    
    canvas.drawPath(highlightPath, brightGoldPaint);
    canvas.drawPath(bowTiePath, outlinePaint);
    
    // Draw collar lines with white - thicker
    final collarPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    
    // Left collar
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.4),
      Offset(size.width * 0.35, size.height * 0.55),
      collarPaint,
    );
    
    // Right collar
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.65, size.height * 0.55),
      collarPaint,
    );
    
    // Draw refined mustache - thicker and more prominent
    final mustachePath = Path();
    mustachePath.moveTo(size.width * 0.5, size.height * 0.65);
    mustachePath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.63,
      size.width * 0.25, size.height * 0.68,
    );
    mustachePath.moveTo(size.width * 0.5, size.height * 0.65);
    mustachePath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.63,
      size.width * 0.75, size.height * 0.68,
    );
    
    final mustachePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(mustachePath, mustachePaint);
    
    // Draw monocle with gold - bigger and brighter
    final monoclePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.15,
      monoclePaint,
    );
    
    // Inner monocle circle with shine effect
    final innerMonoclePaint = Paint()
      ..color = const Color(0xFFF4E4C1).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.12,
      innerMonoclePaint,
    );
    
    // Add lens shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.48),
      size.width * 0.03,
      shinePaint,
    );
    
    // Monocle chain - more visible
    final chainPath = Path();
    chainPath.moveTo(size.width * 0.85, size.height * 0.5);
    chainPath.quadraticBezierTo(
      size.width * 0.92, size.height * 0.6,
      size.width * 0.88, size.height * 0.75,
    );
    
    final chainPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(chainPath, chainPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
