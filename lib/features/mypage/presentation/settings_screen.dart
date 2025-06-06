import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final hasToken = await AuthApi.instance.hasToken();
      if (hasToken) {
        await UserApi.instance.unlink();
        debugPrint('카카오 연결 해제 완료 ✅');
      } else {
        debugPrint('❗ 카카오 토큰 없음 → unlink 생략');
      }
    } catch (e) {
      debugPrint('카카오 연결 해제 실패 ❌: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    if (!context.mounted) return;
    context.go('/login');
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
      body: ListView(
        children: [
          ListTile(
            title: const Text('로그아웃', style: TextStyle(color: Colors.black)),
            onTap: () {
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
                        _handleLogout(context);
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
            onTap: () {
              showDialog(
                context: context,
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
                        // TODO: Implement account deletion logic
                        Navigator.pop(context);
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
    );
  }
} 