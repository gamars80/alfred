import 'package:flutter/material.dart';
import 'package:alfred_clean/features/call/presentation/call_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const CallScreen(),
      const Center(child: Text('홈 화면')),
      _buildMyPage(),
    ]);
  }

  Widget _buildMyPage() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
          onPressed: () async {
            try {
              final hasToken = await AuthApi.instance.hasToken();
              if (hasToken) {
                await UserApi.instance.unlink();
                print('카카오 연결 해제 완료 ✅');
              } else {
                print('❗ 카카오 토큰 없음 → unlink 생략');
              }
            } catch (e) {
              print('카카오 연결 해제 실패 ❌: $e');
            }

            // ✅ JWT 토큰 삭제
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('accessToken');

            if (!context.mounted) return;
            context.go('/login');
          },
        child: const Text('카카오 로그아웃'),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFF6A00),
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '집사호출'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
