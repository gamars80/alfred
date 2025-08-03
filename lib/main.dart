import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'features/auth/data/device_info_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'service/push_notification_service.dart';
// ✅ 전역 navigatorKey 선언 (Dio 인터셉터에서 사용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 백그라운드 메시지 핸들러 (최상위 레벨 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화
  await Firebase.initializeApp();
  
  debugPrint('🔔 [Background] 백그라운드 메시지 수신');
  debugPrint('🔔 [Background] 메시지 데이터: ${message.data}');
  debugPrint('🔔 [Background] 메시지 알림: ${message.notification?.title}');
  
  // 백그라운드에서는 Firebase가 자동으로 시스템 알림을 표시함
  // 추가 로컬 알림은 불필요하므로 로깅만 수행
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Google Mobile Ads SDK 초기화
  await MobileAds.instance.initialize();
  debugPrint('MobileAds initialized successfully');

  // ✅ ATT 권한 요청 (iOS 14+)
  if (Platform.isIOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('Initial ATT status: $status');
    
    if (status == TrackingStatus.notDetermined) {
      debugPrint('Requesting ATT permission...');
      final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('ATT permission result: $newStatus');
    }
    
    // ATT 상태에 따른 광고 설정
    if (status == TrackingStatus.authorized || status == TrackingStatus.denied) {
      debugPrint('ATT status is: $status - Ads should work');
    } else {
      debugPrint('ATT status is: $status - Ads may be limited');
    }
  }

  // Firebase 초기화
  await Firebase.initializeApp();
  
  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 푸시 알림 서비스 초기화
  await PushNotificationService().initialize();

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '22e6b88148da0c4cb1293cbe664cecc4',
    loggingEnabled: true,
  );
  // ✅ .env 환경변수 로드
  await dotenv.load();

  // ✅ 디바이스 정보 초기화 및 업데이트 (백그라운드에서 실행)
  _initializeDeviceInfoInBackground();

  runApp(const AlfredApp());
}

/// 백그라운드에서 디바이스 정보 초기화 및 업데이트
void _initializeDeviceInfoInBackground() {
  // 앱 시작을 지연시키지 않도록 백그라운드에서 실행
  Future.delayed(const Duration(seconds: 2), () async {
    try {
      // 로그인한 사용자라면 홈 화면에서 체크할 예정
      debugPrint('[Main] 앱 시작 - 홈 화면에서 디바이스 정보 체크 예정');
    } catch (e) {
      debugPrint('[Main] 디바이스 정보 초기화 실패: $e');
    }
  });
}
