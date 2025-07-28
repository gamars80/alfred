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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateId(String? value) {
    debugPrint('🔐 [검증] 아이디 검증 시작: "$value"');
    if (value == null || value.isEmpty) {
      debugPrint('🔐 [검증] 아이디 검증 실패: 빈 값');
      return '아이디를 입력해주세요';
    }
    if (value.length >= 10) {
      debugPrint('🔐 [검증] 아이디 검증 실패: 길이 ${value.length} >= 10');
      return '아이디는 10자 미만이어야 합니다';
    }
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(value)) {
      debugPrint('🔐 [검증] 아이디 검증 실패: 영문 소문자와 숫자만 가능');
      return '아이디는 영문 소문자와 숫자만 가능합니다';
    }
    debugPrint('🔐 [검증] 아이디 검증 통과');
    return null;
  }

  String? _validatePassword(String? value) {
    debugPrint('🔐 [검증] 비밀번호 검증 시작: 길이 ${value?.length ?? 0}');
    if (value == null || value.isEmpty) {
      debugPrint('🔐 [검증] 비밀번호 검증 실패: 빈 값');
      return '비밀번호를 입력해주세요';
    }
    if (value.length >= 15) {
      debugPrint('🔐 [검증] 비밀번호 검증 실패: 길이 ${value.length} >= 15');
      return '비밀번호는 15자 미만이어야 합니다';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]+$').hasMatch(value)) {
      debugPrint('🔐 [검증] 비밀번호 검증 실패: 영문, 숫자, 특수문자 포함 필요');
      return '비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다';
    }
    debugPrint('🔐 [검증] 비밀번호 검증 통과');
    return null;
  }

  Future<void> _login() async {
    debugPrint('🔐 [로그인] 시작');
    debugPrint('🔐 [로그인] 아이디: ${_idController.text}');
    debugPrint('🔐 [로그인] 비밀번호 길이: ${_passwordController.text.length}');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('🔐 [로그인] 폼 검증 실패');
      return;
    }
    debugPrint('🔐 [로그인] 폼 검증 통과');

    setState(() => _isLoading = true);
    debugPrint('🔐 [로그인] 로딩 상태 설정 완료');

    try {
      debugPrint('🔐 [로그인] API 호출 시작');
      final loginResp = await my_auth.AuthApi.loginWithIdPassword(
        loginId: _idController.text,
        password: _passwordController.text,
      );
      debugPrint('🔐 [로그인] API 호출 완료');
      debugPrint('🔐 [로그인] 응답: needSignup=${loginResp.needSignup}, token=${loginResp.token != null ? "있음" : "없음"}');

      if (loginResp.needSignup) {
        debugPrint('🔐 [로그인] 회원가입 필요');
        Fluttertoast.showToast(msg: '회원가입을 먼저 해주세요');
        return;
      }

      if (loginResp.token != null) {
        debugPrint('🔐 [로그인] 토큰 저장 시작');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', loginResp.token!);
        debugPrint('🔐 [로그인] 토큰 저장 완료');
        if (mounted) {
          debugPrint('🔐 [로그인] 메인 화면으로 이동');
          context.go('/main');
        }
      } else {
        debugPrint('🔐 [로그인] 토큰이 null');
      }
    } catch (e) {
      debugPrint('🔐 [로그인] 에러 발생: $e');
      debugPrint('🔐 [로그인] 에러 타입: ${e.runtimeType}');
      
      // 구체적인 에러 메시지 표시
      String errorMessage = '로그인에 실패했습니다';
      if (e.toString().contains('Invalid password')) {
        errorMessage = '비밀번호가 올바르지 않습니다';
      } else if (e.toString().contains('User not found')) {
        errorMessage = '존재하지 않는 계정입니다';
      } else if (e.toString().contains('Account locked')) {
        errorMessage = '계정이 잠겨있습니다';
      }
      
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      debugPrint('🔐 [로그인] finally 블록 실행');
      setState(() => _isLoading = false);
    }
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
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
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
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
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
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: '비밀번호',
                                labelStyle: TextStyle(
                                  color: goldColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                hintText: '영문, 숫자, 특수문자 포함 (10자 미만)',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
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
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login button with gold gradient
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
                        onPressed: _isLoading ? null : _login,
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
                                '로그인',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Signup button with subtle styling
                    TextButton(
                      onPressed: () {
                        context.push('/signup');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: goldColor.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 13,
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