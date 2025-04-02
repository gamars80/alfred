import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab.dart';
import 'screens/call_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized(); // 꼭 먼저 호출
  KakaoSdk.init(nativeAppKey: '22e6b88148da0c4cb1293cbe664cecc4');
  // 현재 해시키 콘솔에 출력
  final keyHash = await KakaoSdk.origin;
  print("✅ 현재 해시키: $keyHash");
  runApp(const AlfredApp());
}

class AlfredApp extends StatelessWidget {
  const AlfredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알프레드',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF6A00),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainTab(),
        '/call': (context) => const CallScreen(),
      },
    );
  }
}

