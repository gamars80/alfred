import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// ✅ 전역 navigatorKey 선언 (Dio 인터셉터에서 사용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Google Mobile Ads SDK 초기화
  await MobileAds.instance.initialize();

  // ✅ ATT 권한 요청 (iOS 14+)
  if (Platform.isIOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '22e6b88148da0c4cb1293cbe664cecc4',
    loggingEnabled: true,
  );
  // ✅ .env 환경변수 로드
  await dotenv.load();

  runApp(const AlfredApp());
}
