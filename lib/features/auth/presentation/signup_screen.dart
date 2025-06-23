import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../data/auth_api.dart' as my_auth;

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _privacyPolicyChecked = true;
  bool _termsOfServiceChecked = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String? _validateId(String? value) {
    if (value == null || value.isEmpty) {
      return '아이디를 입력해주세요';
    }
    if (value.length >= 10) {
      return '아이디는 10자 미만이어야 합니다';
    }
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(value)) {
      return '아이디는 영문 소문자와 숫자만 가능합니다';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length >= 15) {
      return '비밀번호는 15자 미만이어야 합니다';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]+$').hasMatch(value)) {
      return '비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다';
    }
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }


  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_privacyPolicyChecked || !_termsOfServiceChecked) {
      Fluttertoast.showToast(msg: '개인정보 처리방침과 이용약관에 동의해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final signupResp = await my_auth.AuthApi.registerNormalUser(
        loginId: _idController.text,
        password: _passwordController.text,
      );

      if (signupResp.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', signupResp.token!);
        if (mounted) {
          Fluttertoast.showToast(msg: '회원가입이 완료되었습니다');
          context.go('/main');
        }
      }
    } catch (e) {
      // 디바이스 차단 에러 메시지 감지
      if (e.toString().contains('This device is blocked from registration')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      } else {
        Fluttertoast.showToast(msg: '회원가입에 실패했습니다');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: const Color(0xFF0A0A0A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: goldColor),
          onPressed: () => context.pop(),
        ),
      ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Alfred butler logo section
                    Container(
                      width: 120,
                      height: 120,
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
                          color: goldColor.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(70, 70),
                          painter: ButlerLogoPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Input fields with dark theme
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goldColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 52,
                            child: TextFormField(
                              controller: _idController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: '아이디',
                                labelStyle: TextStyle(
                                  color: goldColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                hintText: '영문 소문자, 숫자 조합 (10자 미만)',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                isDense: true,
                              ),
                              validator: _validateId,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Divider(color: goldColor.withOpacity(0.3), height: 1),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 52,
                            child: TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: '비밀번호',
                                labelStyle: TextStyle(
                                  color: goldColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                hintText: '영문, 숫자, 특수문자 포함 (15자 미만)',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: goldColor,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Divider(color: goldColor.withOpacity(0.3), height: 1),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 52,
                            child: TextFormField(
                              controller: _passwordConfirmController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: '비밀번호 확인',
                                labelStyle: TextStyle(
                                  color: goldColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                hintText: '비밀번호를 한번 더 입력해주세요',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                                    color: goldColor,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                                ),
                              ),
                              obscureText: _obscurePasswordConfirm,
                              validator: _validatePasswordConfirm,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Privacy Policy and Terms of Service checkboxes
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goldColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _privacyPolicyChecked,
                            onChanged: (value) => setState(() => _privacyPolicyChecked = value ?? true),
                            title: GestureDetector(
                              onTap: () => _openWebView(
                                'https://halved-molybdenum-484.notion.site/1dbf9670410180c0b7c6f9baf0204286',
                                '개인정보 처리방침',
                              ),
                              child: Text(
                                '개인정보 처리방침 동의',
                                style: TextStyle(
                                  color: goldColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            checkColor: const Color(0xFF1A1A1A),
                            activeColor: goldColor,
                            side: BorderSide(color: goldColor),
                          ),
                          Divider(color: goldColor.withOpacity(0.3), height: 1),
                          CheckboxListTile(
                            value: _termsOfServiceChecked,
                            onChanged: (value) => setState(() => _termsOfServiceChecked = value ?? true),
                            title: GestureDetector(
                              onTap: () => _openWebView(
                                'https://halved-molybdenum-484.notion.site/1dbf9670410180b2a3f7ca3670ddb26d',
                                '이용약관',
                              ),
                              child: Text(
                                '이용약관 동의',
                                style: TextStyle(
                                  color: goldColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            checkColor: const Color(0xFF1A1A1A),
                            activeColor: goldColor,
                            side: BorderSide(color: goldColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Signup button with gold gradient
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF4E4C1),
                            goldColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '회원가입',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
}

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
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    
    final brightGoldPaint = Paint()
      ..color = const Color(0xFFF4E4C1)
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
    
    canvas.drawPath(bowTiePath, goldPaint);
    
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.5, size.height * 0.25);
    highlightPath.lineTo(size.width * 0.7, size.height * 0.15);
    highlightPath.lineTo(size.width * 0.65, size.height * 0.2);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.28);
    highlightPath.close();
    
    canvas.drawPath(highlightPath, brightGoldPaint);
    canvas.drawPath(bowTiePath, outlinePaint);
    
    final collarPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.4),
      Offset(size.width * 0.35, size.height * 0.55),
      collarPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.65, size.height * 0.55),
      collarPaint,
    );
    
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
    
    final monoclePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.15,
      monoclePaint,
    );
    
    final innerMonoclePaint = Paint()
      ..color = const Color(0xFFF4E4C1).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.12,
      innerMonoclePaint,
    );
    
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.48),
      size.width * 0.03,
      shinePaint,
    );
    
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