import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/in_app_notification_banner.dart';
import '../main.dart'; // navigatorKey import
import 'package:go_router/go_router.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const String _tokenKey = 'fcm_token';
  static const String _permissionKey = 'notification_permission';

  // 초기화
  Future<void> initialize() async {
    debugPrint('🔔 [PushNotification] 초기화 시작');
    
    try {
      // 1. 권한 요청
      await _requestPermission();
      
      // 2. 로컬 알림 초기화
      await _initializeLocalNotifications();
      
      // 3. 포그라운드 메시지 핸들러 설정
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // 4. 백그라운드 메시지 핸들러 설정
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      // 5. 알림 탭 핸들러 설정
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // 6. 초기 알림 처리 (앱이 종료된 상태에서 알림 탭으로 열린 경우)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
      
      // 7. 토큰 가져오기
      await _getAndSaveToken();
      
      debugPrint('✅ [PushNotification] 초기화 완료');
    } catch (e) {
      debugPrint('❌ [PushNotification] 초기화 실패: $e');
    }
  }

  // 권한 요청
  Future<void> _requestPermission() async {
    debugPrint('🔔 [PushNotification] 권한 요청 시작');
    
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_permissionKey, settings.authorizationStatus.name);
      });
      
      debugPrint('🔔 [PushNotification] 권한 상태: ${settings.authorizationStatus}');
      debugPrint('🔔 [PushNotification] 알림 허용: ${settings.alert}');
      debugPrint('🔔 [PushNotification] 배지 허용: ${settings.badge}');
      debugPrint('🔔 [PushNotification] 소리 허용: ${settings.sound}');
    } catch (e) {
      debugPrint('❌ [PushNotification] 권한 요청 실패: $e');
    }
  }

  // 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    debugPrint('🔔 [PushNotification] 로컬 알림 초기화 시작');
    
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // iOS에서 알림 권한 요청
      if (Platform.isIOS) {
        await _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      debugPrint('✅ [PushNotification] 로컬 알림 초기화 완료');
    } catch (e) {
      debugPrint('❌ [PushNotification] 로컬 알림 초기화 실패: $e');
    }
  }

  // FCM 토큰 가져오기 및 저장
  Future<String?> _getAndSaveToken() async {
    debugPrint('🔔 [PushNotification] FCM 토큰 가져오기 시작');
    
    try {
      String? token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString(_tokenKey, token);
        });
        
        debugPrint('✅ [PushNotification] FCM 토큰 저장 완료: ${token.substring(0, 20)}...');
        return token;
      } else {
        debugPrint('❌ [PushNotification] FCM 토큰을 가져올 수 없음');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [PushNotification] FCM 토큰 가져오기 실패: $e');
      return null;
    }
  }

  // 저장된 토큰 가져오기
  Future<String?> getStoredToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('❌ [PushNotification] 저장된 토큰 가져오기 실패: $e');
      return null;
    }
  }

  // 토큰 새로고침
  Future<String?> refreshToken() async {
    debugPrint('🔔 [PushNotification] 토큰 새로고침 시작');
    
    try {
      String? newToken = await _firebaseMessaging.getToken();
      
      if (newToken != null) {
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString(_tokenKey, newToken);
        });
        
        debugPrint('✅ [PushNotification] 토큰 새로고침 완료: ${newToken.substring(0, 20)}...');
        return newToken;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ [PushNotification] 토큰 새로고침 실패: $e');
      return null;
    }
  }

  // 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 [PushNotification] 포그라운드 메시지 수신');
    debugPrint('🔔 [PushNotification] 메시지 데이터: ${message.data}');
    debugPrint('🔔 [PushNotification] 메시지 알림: ${message.notification?.title}');
    
    // iOS에서는 인앱 알림 배너 사용, Android에서는 로컬 알림 사용
    if (Platform.isIOS) {
      _showInAppNotificationBanner(message);
    } else {
      _showLocalNotification(message);
    }
  }

  // 백그라운드 메시지 처리 (최상위 레벨 함수여야 함)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('🔔 [PushNotification] 백그라운드 메시지 수신');
    debugPrint('🔔 [PushNotification] 메시지 데이터: ${message.data}');
    
    // 백그라운드에서는 자동으로 시스템 알림이 표시됨
  }

  // 알림 탭 처리
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔔 [PushNotification] 알림 탭됨');
    debugPrint('🔔 [PushNotification] 메시지 데이터: ${message.data}');
    
    // 여기서 특정 화면으로 네비게이션 처리
    _handleNotificationNavigation(message.data);
  }

  // 로컬 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [PushNotification] 로컬 알림 탭됨');
    debugPrint('🔔 [PushNotification] 응답 데이터: ${response.payload}');
    
    if (response.payload != null) {
      Map<String, dynamic> data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  // 알림 네비게이션 처리
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('🔔 [PushNotification] 알림 네비게이션 처리 시작');
    debugPrint('🔔 [PushNotification] 받은 데이터: $data');
    debugPrint('🔔 [PushNotification] 데이터 타입: ${data.runtimeType}');
    
    // 현재 컨텍스트 가져오기
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('❌ [PushNotification] 컨텍스트를 찾을 수 없음');
      return;
    }
    
    debugPrint('✅ [PushNotification] 컨텍스트 찾음');
    
    // 알림 데이터에서 화면 정보 추출
    String? screen = data['screen'];
    String? id = data['id'];
    String? type = data['type'];
    
    debugPrint('🔔 [PushNotification] 네비게이션 정보: screen=$screen, id=$id, type=$type');
    
    try {
      switch (screen) {
        case 'product':
          // 상품 상세 화면으로 이동
          debugPrint('🔔 [PushNotification] 상품 상세 화면으로 이동: $id');
          context.go('/product/$id');
          break;
          
        case 'chat':
          // 채팅 화면으로 이동
          debugPrint('🔔 [PushNotification] 채팅 화면으로 이동: $id');
          context.go('/chat/$id');
          break;
          
        case 'call':
          // 콜 화면으로 이동
          debugPrint('🔔 [PushNotification] 콜 화면으로 이동: $id');
          context.go('/call');
          break;
          
        case 'history':
          // 히스토리 화면으로 이동
          debugPrint('🔔 [PushNotification] 히스토리 화면으로 이동: $id');
          context.go('/history');
          break;
          
        case 'home':
          // 홈 화면으로 이동
          debugPrint('🔔 [PushNotification] 홈 화면으로 이동');
          context.go('/main');
          break;
          
        case 'search':
          // 검색 화면으로 이동
          debugPrint('🔔 [PushNotification] 검색 화면으로 이동');
          context.go('/search');
          break;
          
        case 'mypage':
          // 마이페이지로 이동
          debugPrint('🔔 [PushNotification] 마이페이지로 이동');
          context.go('/mypage');
          break;
          
        default:
          // 기본적으로 홈 화면으로 이동
          debugPrint('🔔 [PushNotification] 기본 홈 화면으로 이동');
          context.go('/main');
          break;
      }
      
      debugPrint('✅ [PushNotification] 네비게이션 완료: $screen');
      
    } catch (e) {
      debugPrint('❌ [PushNotification] 네비게이션 실패: $e');
      // 실패 시 기본적으로 홈 화면으로 이동
      try {
        context.go('/main');
      } catch (e2) {
        debugPrint('❌ [PushNotification] 홈 화면 이동도 실패: $e2');
      }
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      debugPrint('🔔 [PushNotification] 로컬 알림 표시 시작');
      debugPrint('🔔 [PushNotification] 제목: ${message.notification?.title}');
      debugPrint('🔔 [PushNotification] 내용: ${message.notification?.body}');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'alfred_channel',
        'Alfred 알림',
        channelDescription: 'Alfred 앱의 주요 알림',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
        icon: '@mipmap/launcher_icon',
      );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        categoryIdentifier: 'alfred_category',
        threadIdentifier: 'alfred_thread',
        // iOS에서 포그라운드에서도 알림 표시
        interruptionLevel: InterruptionLevel.active,
      );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // iOS에서 포그라운드 알림을 강제로 표시하기 위한 추가 설정
      if (Platform.isIOS) {
        // iOS 전용 설정
        await _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      await _localNotifications.show(
        notificationId,
        message.notification?.title ?? '알프레드',
        message.notification?.body ?? '새로운 메시지가 도착했습니다.',
        platformChannelSpecifics,
        payload: json.encode(message.data),
      );
      
      debugPrint('✅ [PushNotification] 로컬 알림 표시 완료 (ID: $notificationId)');
      
      // iOS에서 알림이 표시되었는지 확인
      if (Platform.isIOS) {
        debugPrint('ℹ️ [PushNotification] iOS 알림 표시 확인 - 설정에서 알림 권한을 확인하세요');
      }
      
    } catch (e) {
      debugPrint('❌ [PushNotification] 로컬 알림 표시 실패: $e');
      debugPrint('❌ [PushNotification] 에러 상세: ${e.toString()}');
    }
  }

  // 앱 배지 카운트 설정 (현재는 로깅만)
  Future<void> setBadgeCount(int count) async {
    try {
      debugPrint('✅ [PushNotification] 배지 카운트 설정 요청: $count');
      debugPrint('ℹ️ [PushNotification] 배지 카운트는 서버에서 관리됩니다');
    } catch (e) {
      debugPrint('❌ [PushNotification] 배지 카운트 설정 실패: $e');
    }
  }

  // 앱 배지 카운트 초기화 (현재는 로깅만)
  Future<void> clearBadgeCount() async {
    try {
      debugPrint('✅ [PushNotification] 배지 카운트 초기화 요청');
      debugPrint('ℹ️ [PushNotification] 배지 카운트는 서버에서 관리됩니다');
    } catch (e) {
      debugPrint('❌ [PushNotification] 배지 카운트 초기화 실패: $e');
    }
  }



  // 인앱 알림 배너 표시 (iOS 포그라운드용)
  void _showInAppNotificationBanner(RemoteMessage message) {
    try {
      debugPrint('🔔 [PushNotification] 인앱 알림 배너 표시 시작');
      debugPrint('🔔 [PushNotification] 제목: ${message.notification?.title}');
      debugPrint('🔔 [PushNotification] 내용: ${message.notification?.body}');
      
      // 현재 활성화된 컨텍스트에서 오버레이 표시
      final context = navigatorKey.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (context) => Stack(
            children: [
              InAppNotificationBanner(
                title: message.notification?.title ?? '알프레드',
                message: message.notification?.body ?? '새로운 메시지가 도착했습니다.',
                onTap: () {
                  debugPrint('🔔 [PushNotification] 인앱 알림 배너 탭됨');
                  debugPrint('🔔 [PushNotification] 탭된 메시지 데이터: ${message.data}');
                  _handleNotificationNavigation(message.data);
                },
                onDismiss: () {
                  debugPrint('🔔 [PushNotification] 인앱 알림 배너 닫힘');
                },
              ),
            ],
          ),
        );
        debugPrint('✅ [PushNotification] 인앱 알림 배너 표시 완료');
      } else {
        debugPrint('❌ [PushNotification] 컨텍스트를 찾을 수 없음');
      }
    } catch (e) {
      debugPrint('❌ [PushNotification] 인앱 알림 배너 표시 실패: $e');
    }
  }

  // 토큰 삭제 (로그아웃 시)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove(_tokenKey);
      });
      debugPrint('✅ [PushNotification] 토큰 삭제 완료');
    } catch (e) {
      debugPrint('❌ [PushNotification] 토큰 삭제 실패: $e');
    }
  }
} 