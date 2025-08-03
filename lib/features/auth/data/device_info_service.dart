import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../common/dio/dio_client.dart';
import '../../../service/token_manager.dart';
import '../../../service/push_notification_service.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 디바이스 고유 ID를 가져옵니다
  static Future<String> getDeviceUniqueId() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      final id = androidInfo.data['androidId'];
      if (id != null && id != 'unknown') {
        return id;
      }
      // Fallback: 앱 자체 UUID
      final prefs = await SharedPreferences.getInstance();
      String? uuid = prefs.getString('app_device_uuid');
      if (uuid == null) {
        uuid = const Uuid().v4();
        await prefs.setString('app_device_uuid', uuid);
      }
      return uuid;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  /// OS 타입을 가져옵니다 (AOS 또는 IOS)
  static String getOsType() {
    if (Platform.isAndroid) {
      return 'AOS';
    } else if (Platform.isIOS) {
      return 'IOS';
    }
    return 'UNKNOWN';
  }

  /// 앱 버전을 가져옵니다
  static Future<String?> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return null;
    }
  }

  /// 푸시 토큰을 가져옵니다
  static Future<String?> getDevicePushToken() async {
    try {
      debugPrint('🔍 [DeviceInfo] 푸시 알림 서비스에서 토큰 가져오기 시작');
      
      // 푸시 알림 서비스에서 저장된 토큰 가져오기
      String? token = await PushNotificationService().getStoredToken();
      
      if (token == null) {
        debugPrint('📱 [DeviceInfo] 저장된 토큰이 없음, 새로 가져오기 시도');
        token = await PushNotificationService().refreshToken();
      }
      
      debugPrint('📱 [DeviceInfo] 푸시 토큰: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
      
      if (token == null) {
        debugPrint('❌ [DeviceInfo] 푸시 토큰이 null입니다');
        debugPrint('❌ [DeviceInfo] 가능한 원인:');
        debugPrint('   - Firebase 설정 문제');
        debugPrint('   - 네트워크 연결 문제');
        debugPrint('   - iOS 시뮬레이터 (실제 기기에서만 작동)');
      }
      
      return token;
    } catch (e) {
      debugPrint('❌ [DeviceInfo] 푸시 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// 모든 디바이스 정보를 한번에 가져옵니다
  static Future<Map<String, dynamic>> getAllDeviceInfo() async {
    final deviceUniqueId = await getDeviceUniqueId();
    final osType = getOsType();
    final appVersion = await getAppVersion();
    final devicePushToken = await getDevicePushToken();

    return {
      'deviceUniqueId': deviceUniqueId,
      'osType': osType,
      'appVersion': appVersion,
      'devicePushToken': devicePushToken,
    };
  }

  /// 홈 화면 진입 시 디바이스 정보 체크 및 업데이트
  static Future<void> checkDeviceInfoOnHomeEnter() async {
    debugPrint('🔍 [DeviceInfo] 홈 화면 진입 시 디바이스 정보 체크 시작');
    
    try {
      // 로그인한 사용자인지 확인
      final token = await TokenManager.getToken();
      debugPrint('🔍 [DeviceInfo] 토큰 확인: ${token != null ? "있음 (${token.length}자)" : "없음"}');
      
      if (token == null || token.isEmpty) {
        debugPrint('❌ [DeviceInfo] 로그인하지 않은 사용자 - 체크 건너뜀');
        return;
      }

      debugPrint('✅ [DeviceInfo] 로그인한 사용자 확인됨');

      final prefs = await SharedPreferences.getInstance();
      
      // 현재 앱 버전과 푸시 토큰 가져오기
      debugPrint('🔍 [DeviceInfo] 현재 디바이스 정보 가져오기 시작');
      final currentAppVersion = await getAppVersion();
      final currentPushToken = await getDevicePushToken();
      
      debugPrint('📱 [DeviceInfo] 현재 앱 버전: $currentAppVersion');
      debugPrint('📱 [DeviceInfo] 현재 푸시 토큰: ${currentPushToken != null ? "${currentPushToken.substring(0, 10)}..." : "null"}');
      
      // 백엔드에서 현재 디바이스 정보 가져오기
      debugPrint('🌐 [DeviceInfo] 백엔드에서 디바이스 정보 가져오기 시작');
      final backendDeviceInfo = await _getBackendDeviceInfo();
      
      bool needsUpdate = false;
      Map<String, dynamic> updateData = {};
      
      // 앱 버전 변경 확인 (백엔드와 비교)
      final backendAppVersion = backendDeviceInfo?['appVersion'];
      if (currentAppVersion != null && currentAppVersion != backendAppVersion) {
        debugPrint('🔄 [DeviceInfo] 앱 버전 변경 감지: $backendAppVersion → $currentAppVersion');
        updateData['appVersion'] = currentAppVersion;
        needsUpdate = true;
        await prefs.setString('saved_app_version', currentAppVersion);
        debugPrint('💾 [DeviceInfo] 새로운 앱 버전 저장됨');
      } else {
        debugPrint('✅ [DeviceInfo] 앱 버전 변경 없음');
      }
      
      // 푸시 토큰 변경 확인 (백엔드와 비교)
      final backendPushToken = backendDeviceInfo?['devicePushToken'];
      if (currentPushToken != null && currentPushToken != backendPushToken) {
        debugPrint('🔄 [DeviceInfo] 푸시 토큰 변경 감지: ${backendPushToken != null ? "${backendPushToken.toString().substring(0, 10)}..." : "null"} → ${currentPushToken.substring(0, 10)}...');
        updateData['devicePushToken'] = currentPushToken;
        needsUpdate = true;
        await prefs.setString('saved_push_token', currentPushToken);
        debugPrint('💾 [DeviceInfo] 새로운 푸시 토큰 저장됨');
      } else {
        debugPrint('✅ [DeviceInfo] 푸시 토큰 변경 없음');
      }
      
      // 변경사항이 있으면 백엔드에 업데이트
      if (needsUpdate) {
        debugPrint('🚀 [DeviceInfo] 변경사항 감지됨 - 백엔드 업데이트 시작');
        debugPrint('📤 [DeviceInfo] 업데이트 데이터: $updateData');
        await _updateDeviceInfoToBackend(updateData);
      } else {
        debugPrint('✅ [DeviceInfo] 변경사항 없음 - API 호출 건너뜀');
      }
      
      debugPrint('✅ [DeviceInfo] 홈 화면 진입 시 디바이스 정보 체크 완료');
      
    } catch (e) {
      debugPrint('❌ [DeviceInfo] 디바이스 정보 체크 중 에러: $e');
      debugPrint('❌ [DeviceInfo] 에러 스택: ${StackTrace.current}');
    }
  }

  /// 백엔드에 디바이스 정보 업데이트
  static Future<void> _updateDeviceInfoToBackend(Map<String, dynamic> updateData) async {
    try {
      debugPrint('🌐 [DeviceInfo] 백엔드 업데이트 시작');
      debugPrint('📤 [DeviceInfo] 업데이트 데이터: $updateData');
      
      // deviceId는 현재 사용자의 디바이스 ID를 가져와야 함
      debugPrint('🔍 [DeviceInfo] 디바이스 ID 가져오기 시작');
      final deviceId = await _getCurrentUserDeviceId();
      
      if (deviceId == null) {
        debugPrint('❌ [DeviceInfo] 디바이스 ID를 찾을 수 없음 - 업데이트 중단');
        return;
      }
      
      debugPrint('✅ [DeviceInfo] 디바이스 ID 확인됨: $deviceId');
      debugPrint('🌐 [DeviceInfo] API 호출: PUT /api/user/device/$deviceId');
      
      final response = await DioClient.dio.put(
        '/api/user/device/$deviceId',
        data: updateData,
      );
      
      debugPrint('✅ [DeviceInfo] 백엔드 업데이트 성공');
      debugPrint('📊 [DeviceInfo] 응답 상태 코드: ${response.statusCode}');
      debugPrint('📄 [DeviceInfo] 응답 데이터: ${response.data}');
      
    } catch (e) {
      debugPrint('❌ [DeviceInfo] 백엔드 업데이트 실패');
      debugPrint('❌ [DeviceInfo] 에러 메시지: $e');
      debugPrint('❌ [DeviceInfo] 에러 타입: ${e.runtimeType}');
      
      if (e is DioException) {
        debugPrint('❌ [DeviceInfo] DioException 상세 정보:');
        debugPrint('   - 상태 코드: ${e.response?.statusCode}');
        debugPrint('   - 응답 데이터: ${e.response?.data}');
        debugPrint('   - 요청 URL: ${e.requestOptions.uri}');
        debugPrint('   - 요청 메서드: ${e.requestOptions.method}');
      }
      
      // 실패해도 앱 동작에는 영향 없도록 함
    }
  }

  /// 백엔드에서 현재 사용자의 디바이스 정보를 가져오는 메서드
  static Future<Map<String, dynamic>?> _getBackendDeviceInfo() async {
    try {
      debugPrint('🔍 [DeviceInfo] 백엔드에서 디바이스 정보 가져오기 시작');
      debugPrint('🌐 [DeviceInfo] API 호출: GET /api/user/device');
      
      final response = await DioClient.dio.get('/api/user/device');
      debugPrint('📊 [DeviceInfo] 디바이스 정보 API 응답 상태: ${response.statusCode}');
      
      final responseData = response.data as Map<String, dynamic>;
      debugPrint('📄 [DeviceInfo] 디바이스 정보 응답 데이터: $responseData');
      
      final devices = responseData['devices'] as List<dynamic>?;
      
      if (devices != null && devices.isNotEmpty) {
        final firstDevice = devices.first as Map<String, dynamic>;
        debugPrint('✅ [DeviceInfo] 백엔드 디바이스 정보 가져옴: $firstDevice');
        return firstDevice;
      }
      
      debugPrint('❌ [DeviceInfo] 백엔드에서 디바이스 정보를 찾을 수 없음');
      return null;
      
    } catch (e) {
      debugPrint('❌ [DeviceInfo] 백엔드 디바이스 정보 가져오기 실패');
      debugPrint('❌ [DeviceInfo] 에러 메시지: $e');
      debugPrint('❌ [DeviceInfo] 에러 타입: ${e.runtimeType}');
      
      if (e is DioException) {
        debugPrint('❌ [DeviceInfo] DioException 상세 정보:');
        debugPrint('   - 상태 코드: ${e.response?.statusCode}');
        debugPrint('   - 응답 데이터: ${e.response?.data}');
        debugPrint('   - 요청 URL: ${e.requestOptions.uri}');
      }
      
      return null;
    }
  }

  /// 현재 사용자의 디바이스 ID를 가져오는 메서드
  static Future<String?> _getCurrentUserDeviceId() async {
    try {
      debugPrint('🔍 [DeviceInfo] 디바이스 ID 가져오기 시작');
      
      // 로컬에 저장된 deviceId 사용 (회원가입 시 저장)
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('user_device_id');
      
      if (deviceId != null) {
        debugPrint('✅ [DeviceInfo] 로컬에서 디바이스 ID 가져옴: $deviceId');
        return deviceId;
      }
      
      // 로컬에 없으면 디바이스 정보 API에서 가져오기
      debugPrint('🔍 [DeviceInfo] 로컬에 deviceId 없음, API에서 가져오기 시도');
      debugPrint('🌐 [DeviceInfo] API 호출: GET /api/user/device');
      
      final response = await DioClient.dio.get('/api/user/device');
      debugPrint('📊 [DeviceInfo] 디바이스 정보 API 응답 상태: ${response.statusCode}');
      
      final responseData = response.data as Map<String, dynamic>;
      debugPrint('📄 [DeviceInfo] 디바이스 정보 응답 데이터: $responseData');
      
      final devices = responseData['devices'] as List<dynamic>?;
      
      if (devices != null && devices.isNotEmpty) {
        final firstDevice = devices.first as Map<String, dynamic>;
        final apiDeviceId = firstDevice['deviceId']?.toString();
        
        if (apiDeviceId != null) {
          // API에서 가져온 deviceId를 로컬에 저장
          await prefs.setString('user_device_id', apiDeviceId);
          debugPrint('✅ [DeviceInfo] API에서 디바이스 ID 가져와서 저장: $apiDeviceId');
          return apiDeviceId;
        }
      }
      
      debugPrint('❌ [DeviceInfo] 디바이스 정보에 deviceId가 없음');
      debugPrint('📄 [DeviceInfo] 디바이스 정보: $responseData');
      return null;
      
    } catch (e) {
      debugPrint('❌ [DeviceInfo] 디바이스 ID 가져오기 실패');
      debugPrint('❌ [DeviceInfo] 에러 메시지: $e');
      debugPrint('❌ [DeviceInfo] 에러 타입: ${e.runtimeType}');
      
      if (e is DioException) {
        debugPrint('❌ [DeviceInfo] DioException 상세 정보:');
        debugPrint('   - 상태 코드: ${e.response?.statusCode}');
        debugPrint('   - 응답 데이터: ${e.response?.data}');
        debugPrint('   - 요청 URL: ${e.requestOptions.uri}');
      }
      
      return null;
    }
  }

  /// 회원가입 시 디바이스 정보 초기 저장
  static Future<void> saveDeviceInfoOnSignup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 현재 값들을 저장
      final currentAppVersion = await getAppVersion();
      final currentPushToken = await getDevicePushToken();
      
      if (currentAppVersion != null) {
        await prefs.setString('saved_app_version', currentAppVersion);
      }
      
      if (currentPushToken != null) {
        await prefs.setString('saved_push_token', currentPushToken);
      }
      
      debugPrint('[DeviceInfo] 회원가입 시 디바이스 정보 저장 완료');
      
    } catch (e) {
      debugPrint('[DeviceInfo] 디바이스 정보 저장 실패: $e');
    }
  }

  /// 회원가입 응답에서 deviceId를 저장
  static Future<void> saveDeviceIdFromSignupResponse(Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 회원가입 응답에서 deviceId 추출
      final deviceId = responseData['deviceId'] as String?;
      if (deviceId != null) {
        await prefs.setString('user_device_id', deviceId);
        debugPrint('[DeviceInfo] 디바이스 ID 저장 완료: $deviceId');
      } else {
        debugPrint('[DeviceInfo] 회원가입 응답에 deviceId가 없음');
      }
      
    } catch (e) {
      debugPrint('[DeviceInfo] 디바이스 ID 저장 실패: $e');
    }
  }
} 