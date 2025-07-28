import 'package:flutter/material.dart';
import 'package:alfred_clean/features/call/presentation/call_screen.dart';
import 'package:alfred_clean/features/history/presentation/history_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/presentation/home_screen.dart';
import '../../like/presentation/liked_product_screen.dart';
import '../../mypage/presentation/mypage_screen.dart';

class MainTab extends StatefulWidget {

  final int selectedIndex;
  final int? selectedBeautyTab;
  final int? selectedFoodTab;
  final int? selectedBeautyCareTab;
  const MainTab({super.key, this.selectedIndex = 0, this.selectedBeautyTab, this.selectedFoodTab, this.selectedBeautyCareTab});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    debugPrint('✅ MainTab selectedIndex: $_selectedIndex'); // 🔍 로그
    _screens.addAll([
      const CallScreen(),
      HistoryScreen(selectedBeautyTab: widget.selectedBeautyTab, selectedFoodTab: widget.selectedFoodTab, selectedBeautyCareTab: widget.selectedBeautyCareTab),
      const HomeScreen(),
      const LikedProductScreen(),
      const MyPageScreen(),
    ]);
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '집사호출'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '히스토리'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜목록'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
