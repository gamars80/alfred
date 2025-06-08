import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mypage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final MyPageService _myPageService = MyPageService();
  bool _isProcessing = false;

  Future<void> _handleLogout() async {
    setState(() => _isProcessing = true);
    
    try {
      // 1. 카카오 로그아웃
      try {
        final hasToken = await AuthApi.instance.hasToken();
        if (hasToken) {
          await UserApi.instance.logout();
          debugPrint('카카오 로그아웃 완료 ✅');
        } else {
          debugPrint('❗ 카카오 토큰 없음 → 로그아웃 생략');
        }
      } catch (e) {
        debugPrint('카카오 로그아웃 실패 ❌: $e');
      }

      // 2. 로컬 토큰 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      // await prefs.remove('kakao_code_verifier');

      // 3. 로그인 화면으로 이동
      if (!mounted) return;
      context.go('/login');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleWithdraw() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _myPageService.withdrawUser();

      if (!mounted) return;

      if (success) {
        // ✅ 카카오 계정 연결 끊기
        try {
          await UserApi.instance.unlink();
          debugPrint('카카오 연결 끊기 완료 ✅');
        } catch (e) {
          debugPrint('카카오 unlink 실패 ❌: $e');
        }

        // ✅ 로그아웃 프로세스 실행
        await _handleLogout();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원탈퇴 처리 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('회원탈퇴 처리 중 예외 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원탈퇴 처리 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              ListTile(
                title: const Text('로그아웃', style: TextStyle(color: Colors.black)),
                onTap: _isProcessing
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('로그아웃', style: TextStyle(color: Colors.black)),
                            content: const Text('정말 로그아웃 하시겠습니까?', style: TextStyle(color: Colors.black)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소', style: TextStyle(color: Colors.black54)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleLogout();
                                },
                                child: const Text('확인', style: TextStyle(color: Color(0xFFFF6A00))),
                              ),
                            ],
                          ),
                        );
                      },
              ),
              const Divider(height: 1, color: Colors.black12),
              ListTile(
                title: const Text(
                  '회원탈퇴',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _isProcessing
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('회원탈퇴', style: TextStyle(color: Colors.black)),
                            content: const Text(
                              '정말 탈퇴하시겠습니까?\n탈퇴 후에는 복구가 불가능합니다.',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소', style: TextStyle(color: Colors.black54)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleWithdraw();
                                },
                                child: const Text(
                                  '탈퇴',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
              ),
              const Divider(height: 1, color: Colors.black12),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 