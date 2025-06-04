import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_api.dart' as my_auth;

class IdPasswordLoginScreen extends StatefulWidget {
  const IdPasswordLoginScreen({Key? key}) : super(key: key);

  @override
  State<IdPasswordLoginScreen> createState() => _IdPasswordLoginScreenState();
}

class _IdPasswordLoginScreenState extends State<IdPasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

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
    if (value.length >= 10) {
      return '비밀번호는 10자 미만이어야 합니다';
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loginResp = await my_auth.AuthApi.loginWithIdPassword(
        loginId: _idController.text,
        password: _passwordController.text,
      );

      if (loginResp.needSignup) {
        Fluttertoast.showToast(msg: '회원가입을 먼저 해주세요');
        return;
      }

      if (loginResp.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', loginResp.token!);
        if (mounted) context.go('/main');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '로그인에 실패했습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
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
                    const SizedBox(height: 40),
                    // Alfred butler logo section
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
                          color: const Color(0xFFD4AF37).withOpacity(0.6),
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
                    // App name in Korean with gold gradient
                    Stack(
                      children: [
                        // Shadow layer for depth
                        Text(
                          '알프레드',
                          textAlign: TextAlign.center,
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
                              const Color(0xFFF4E4C1),
                              const Color(0xFFD4AF37),
                              const Color(0xFFF4E4C1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            '알프레드',
                            textAlign: TextAlign.center,
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
                    const SizedBox(height: 50),
                    // Input fields with dark theme
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _idController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '아이디',
                              labelStyle: TextStyle(color: const Color(0xFFD4AF37).withOpacity(0.8)),
                              hintText: '영문 소문자, 숫자 조합 (10자 미만)',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: _validateId,
                            textInputAction: TextInputAction.next,
                          ),
                          Divider(color: const Color(0xFFD4AF37).withOpacity(0.3), height: 1),
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              labelStyle: TextStyle(color: const Color(0xFFD4AF37).withOpacity(0.8)),
                              hintText: '영문, 숫자, 특수문자 포함 (10자 미만)',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFD4AF37),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            textInputAction: TextInputAction.next,
                          ),
                          Divider(color: const Color(0xFFD4AF37).withOpacity(0.3), height: 1),
                          TextFormField(
                            controller: _passwordConfirmController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '비밀번호 확인',
                              labelStyle: TextStyle(color: const Color(0xFFD4AF37).withOpacity(0.8)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFD4AF37),
                                ),
                                onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                              ),
                            ),
                            obscureText: _obscurePasswordConfirm,
                            validator: _validatePasswordConfirm,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login button with gold gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF4E4C1),
                            const Color(0xFFD4AF37),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                '로그인',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Signup button with subtle styling
                    TextButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: '회원가입 화면은 추후 구현 예정입니다');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
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

// Custom painter for Alfred butler logo
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