import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ✅ 전역 navigatorKey 선언 (Dio 인터셉터에서 사용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Google Mobile Ads SDK 초기화
  await MobileAds.instance.initialize();

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '636c3e43525e486f2e79eae490764c37',
    // javaScriptAppKey: '...사용 중이면 설정...',
    loggingEnabled: true,
  );
  // ✅ .env 환경변수 로드
  await dotenv.load();

  runApp(const AlfredApp());
}
