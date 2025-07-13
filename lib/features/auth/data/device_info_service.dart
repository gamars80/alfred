import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  /// 푸시 토큰을 가져옵니다 (임시로 null 반환)
  /// 실제 구현시에는 Firebase Messaging이나 다른 푸시 서비스를 사용해야 합니다
  static Future<String?> getDevicePushToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
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
} 