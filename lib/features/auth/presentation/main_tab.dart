import 'package:flutter/material.dart';
import 'package:alfred_clean/features/call/presentation/call_screen.dart';
import 'package:alfred_clean/features/history/presentation/history_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/presentation/home_screen.dart';
import '../../like/presentation/liked_product_screen.dart';
import '../../mypage/presentation/mypage_screen.dart';
import '../data/device_info_service.dart';

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
    
    // 홈 화면 진입 시 디바이스 정보 체크
    _checkDeviceInfoOnHomeEnter();
  }

  /// 홈 화면 진입 시 디바이스 정보 체크
  void _checkDeviceInfoOnHomeEnter() {
    debugPrint('🏠 [MainTab] 홈 화면 진입 - 디바이스 정보 체크 예약');
    
    // 백그라운드에서 실행하여 UI 블로킹 방지
    Future.delayed(const Duration(milliseconds: 500), () async {
      debugPrint('🏠 [MainTab] 디바이스 정보 체크 시작 (500ms 지연 후)');
      try {
        await DeviceInfoService.checkDeviceInfoOnHomeEnter();
        debugPrint('✅ [MainTab] 디바이스 정보 체크 완료');
      } catch (e) {
        debugPrint('❌ [MainTab] 디바이스 정보 체크 실패');
        debugPrint('❌ [MainTab] 에러 메시지: $e');
        debugPrint('❌ [MainTab] 에러 타입: ${e.runtimeType}');
      }
    });
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
