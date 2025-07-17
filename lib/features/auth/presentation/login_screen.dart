import 'package:alfred_clean/features/auth/presentation/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/auth_api.dart' as my_auth;
import '../model/login_response.dart';
import '../model/signup_response.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isProcessingCode = false;
  bool _isSignedUp = false;  // Add flag to track signup status
  String? _codeVerifier; // 메모리 기반 code_verifier
  bool _loginSuccess = false; // 로그인 성공 플래그
  String? _errorMessage; // 에러 메시지 상태 추가
  String? _lastProcessedCode; // 마지막으로 처리한 code 값 기억

  /// Navigate to WebView with url and title
  void _openWebView(BuildContext context, String url, String title) {
    debugPrint('url:::::::::::::::::::$url');
    final uriString = Uri(
      path: '/webview',
      queryParameters: {'url': url, 'title': title},
    ).toString();
    context.push(uriString);
  }

  Future<void> _handleKakaoLogin(BuildContext context, String loginId, String email, String name, String phoneNumber) async {
    try {
      final loginResp = await my_auth.AuthApi.loginWithKakaoId(loginId);

      if (loginResp.needSignup) {
        final agreed = await _showAgreementBottomSheet(context);
        if (!agreed) return;

        final signupResp = await my_auth.AuthApi.registerKakaoUser(
          loginId: loginId,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );

        if (signupResp.token == null || signupResp.token!.isEmpty) {
          if (!mounted) return;
          _showError(context, '회원가입 후 토큰 발급에 실패했습니다');
          return;
        }

        if (!mounted) return;
        await _saveTokenAndNavigate(context, signupResp.token!, route: '/main');
      } else {
        if (!mounted) return;
        await _saveTokenAndNavigate(context, loginResp.token, route: '/main');
      }
    } catch (e, stack) {
      debugPrint("카카오 로그인 핸들링 실패: $e\n$stack");
      if (!mounted) return;
      // 디바이스 차단 에러 메시지 감지
      if (e.toString().contains('This device is blocked from registration')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      } else {
        _showError(context, '로그인에 실패했습니다');
      }
    }
  }

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // 1. code_verifier 생성 및 메모리에 저장
      _codeVerifier = _generateCodeVerifier();
      final isKakaoInstalled = await isKakaoTalkInstalled();
      debugPrint('isKakaoTalkInstalled: $isKakaoInstalled');
      if (!isKakaoInstalled) {
        _showError(context, '카카오톡이 설치되어 있어야 로그인할 수 있습니다.');
        return;
      }
      // 2. 카카오톡 앱 로그인 시도
      final token = await UserApi.instance.loginWithKakaoTalk();
      await _afterLogin(context, token);
    } catch (e) {
      debugPrint("카카오 로그인 실패: $e");
      _showError(context, '카카오 로그인에 실패했습니다. $e');
      _codeVerifier = null;
    }
  }

  String _generateCodeVerifier() {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(64, (_) => charset[rand.nextInt(charset.length)]).join();
  }

  Future<void> _afterLogin(BuildContext context, OAuthToken token) async {
    await TokenManagerProvider.instance.manager.setToken(token);
    final user = await UserApi.instance.me();
    final loginId = user.id.toString();
    final email = user.kakaoAccount?.email ?? '';
    final name = user.kakaoAccount?.profile?.nickname ?? '';
    final phoneNumber = user.kakaoAccount?.phoneNumber ?? '';

    await _handleKakaoLogin(context, loginId, email, name, phoneNumber);
  }

  Future<void> _loginWithApple(BuildContext context) async {
    try {
      // 애플 로그인 가능 여부 확인
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        _showError(context, '애플 로그인을 사용할 수 없습니다.');
        return;
      }

      // 애플 로그인 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // p8 키 파일 경로 설정
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.gamars.alfred',
          redirectUri: Uri.parse('https://your-backend-url.com/auth/apple/callback'),
        ),
      );

      // 애플 사용자 정보 추출
      final loginId = credential.userIdentifier ?? '';
      final email = credential.email ?? '';
      final firstName = credential.givenName ?? '';
      final lastName = credential.familyName ?? '';
      final name = '$firstName $lastName'.trim();

      if (loginId.isEmpty) {
        _showError(context, '애플 로그인에 실패했습니다.');
        return;
      }

      await _handleAppleLogin(context, loginId, email, name);
    } catch (e) {
      debugPrint("애플 로그인 실패: $e");
      _showError(context, '애플 로그인에 실패했습니다.');
    }
  }

  Future<void> _handleAppleLogin(BuildContext context, String loginId, String email, String name) async {
    try {
      final loginResp = await my_auth.AuthApi.loginWithAppleId(loginId);

      if (loginResp.needSignup) {
        final agreed = await _showAgreementBottomSheet(context);
        if (!agreed) return;

        final signupResp = await my_auth.AuthApi.registerAppleUser(
          loginId: loginId,
          email: email,
          name: name,
        );

        if (signupResp.token == null || signupResp.token!.isEmpty) {
          if (!mounted) return;
          _showError(context, '회원가입 후 토큰 발급에 실패했습니다');
          return;
        }

        if (!mounted) return;
        await _saveTokenAndNavigate(context, signupResp.token!, route: '/main');
      } else {
        if (!mounted) return;
        await _saveTokenAndNavigate(context, loginResp.token, route: '/main');
      }
    } catch (e, stack) {
      debugPrint("애플 로그인 핸들링 실패: $e\n$stack");
      if (!mounted) return;
      // 디바이스 차단 에러 메시지 감지
      if (e.toString().contains('This device is blocked from registration')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      } else {
        _showError(context, '로그인에 실패했습니다');
      }
    }
  }


  Future<void> _saveTokenAndNavigate(
      BuildContext context,
      String? token, {
        required String route,
      }) async {
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      _showError(context, '유효하지 않은 토큰입니다');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    if (!mounted) return;
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
      backgroundColor: Colors.white,
      builder: (ctx) {
        bool agreeTos = true;
        bool agreePrivacy = true;
        return StatefulBuilder(
          builder: (ctx, setState) {
            final bottom = MediaQuery.of(ctx).viewInsets.bottom;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: bottom + 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text('약관 동의', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        value: agreeTos,
                        onChanged: (v) => setState(() => agreeTos = v!),
                        title: GestureDetector(
                          onTap: () => _openWebView(context, tosUrl, '이용약관'),
                          child: const Text('이용약관 (필수)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFFD4AF37),
                      ),
                      CheckboxListTile(
                        value: agreePrivacy,
                        onChanged: (v) => setState(() => agreePrivacy = v!),
                        title: GestureDetector(
                          onTap: () => _openWebView(context, privacyUrl, '개인정보처리 취급방침'),
                          child: const Text('개인정보처리 취급방침 (필수)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('취소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text('동의 및 계속', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
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
    // build에서는 code 파라미터 처리 X, 오직 UI만 렌더링
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
                        'ALFRED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                          height: 1.2,
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
                        width: double.infinity,
                        height: 56,
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
                    
                    // Apple login button - iOS only
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      GestureDetector(
                        onTap: () => _loginWithApple(context),
                        child: SvgPicture.asset(
                          'assets/icon/apple_login_button.svg',
                          width: double.infinity,
                          height: 56,
                          fit: BoxFit.contain,
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
                    // 로그인 처리 중에는 로딩 인디케이터, 아닐 때만 에러 메시지 표시
                    if (_isProcessingCode)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// Custom painter for Alfred butler logo
class ButlerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;

    // Draw bow tie
    final bowTiePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.15)
      ..lineTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.3, size.height * 0.15)
      ..close();
    
    canvas.drawPath(bowTiePath, paint);
    
    // Draw collar with more elegant style
    final collarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Left collar with elegant curve
    final leftCollarPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.5,
        size.width * 0.35, size.height * 0.55,
      );
    canvas.drawPath(leftCollarPath, collarPaint);
    
    // Right collar with elegant curve
    final rightCollarPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.5,
        size.width * 0.65, size.height * 0.55,
      );
    canvas.drawPath(rightCollarPath, collarPaint);
    
    // Draw refined mustache
    final mustachePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.68,
        size.width * 0.65, size.height * 0.65,
      );
    
    final mustachePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(mustachePath, mustachePaint);
    
    // Draw monocle with more refined style
    final monoclePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.15,
      monoclePaint,
    );
    
    // Draw monocle chain with elegant curve
    final chainPath = Path()
      ..moveTo(size.width * 0.85, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.92, size.height * 0.6,
        size.width * 0.88, size.height * 0.75,
      );
    
    final chainPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(chainPath, chainPaint);

    // Add subtle details
    // Eyebrows
    final eyebrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Left eyebrow
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.33),
      eyebrowPaint,
    );

    // Right eyebrow
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.33),
      eyebrowPaint,
    );

    // Add subtle smile
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.72,
        size.width * 0.6, size.height * 0.7,
      );

    final smilePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(smilePath, smilePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for Apple logo
class AppleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw Apple logo (simplified version)
    final applePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.15, size.width * 0.7, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.25, size.width * 0.75, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.45, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.35, size.width * 0.4, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.45, size.width * 0.25, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.25, size.width * 0.3, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.15, size.width * 0.5, size.height * 0.2)
      ..close();
    
    canvas.drawPath(applePath, paint);
    
    // Draw apple stem
    final stemPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.15),
      stemPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
