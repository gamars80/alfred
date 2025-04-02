import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab.dart';
import 'screens/call_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Android에서 WebView 플랫폼 설정 (SurfaceAndroidWebView 대신 AndroidWebView 사용)
  // if (Platform.isAndroid) {
  //   WebView.platform = AndroidWebView();
  // }

  KakaoSdk.init(nativeAppKey: '22e6b88148da0c4cb1293cbe664cecc4');
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
