import 'package:alfred_clean/routing/router.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/kakao_callback_screen.dart';
import 'common/theme/app_theme.dart';
import 'features/auth/data/device_info_service.dart';

class AlfredApp extends StatefulWidget {
  const AlfredApp({super.key});

  @override
  State<AlfredApp> createState() => _AlfredAppState();
}

class _AlfredAppState extends State<AlfredApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 앱이 포그라운드로 돌아올 때 디바이스 정보 확인
    if (state == AppLifecycleState.resumed) {
      _checkDeviceInfoOnResume();
    }
  }

  /// 앱이 포그라운드로 돌아올 때 디바이스 정보 확인
  void _checkDeviceInfoOnResume() {
    // 백그라운드에서 실행하여 UI 블로킹 방지
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await DeviceInfoService.checkDeviceInfoOnHomeEnter();
      } catch (e) {
        debugPrint('[App] 디바이스 정보 확인 실패: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alfred',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}


