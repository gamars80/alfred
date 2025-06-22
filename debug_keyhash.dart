import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class KeyHashDebugger {
  static Future<void> showKeyHashInfo(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      String keyHash = "알 수 없음";
      
      if (Platform.isAndroid) {
        // Android에서 키 해시 정보 출력
        debugPrint("=== 키 해시 디버그 정보 ===");
        debugPrint("패키지명: ${packageInfo.packageName}");
        debugPrint("앱 버전: ${packageInfo.version}");
        debugPrint("빌드 번호: ${packageInfo.buildNumber}");
        debugPrint("앱 이름: ${packageInfo.appName}");
        
        // 키 해시는 Android 네이티브에서만 확인 가능
        keyHash = "Android 키 해시는 네이티브 코드에서만 확인 가능";
      }
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('키 해시 디버그 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('패키지명: ${packageInfo.packageName}'),
                Text('앱 버전: ${packageInfo.version}'),
                Text('빌드 번호: ${packageInfo.buildNumber}'),
                Text('앱 이름: ${packageInfo.appName}'),
                const SizedBox(height: 10),
                const Text('키 해시 확인 방법:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('1. Android Studio에서 Logcat 확인'),
                const Text('2. 카카오 SDK 로그에서 키 해시 출력 확인'),
                const Text('3. 또는 네이티브 코드에서 직접 출력'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("키 해시 디버그 에러: $e");
    }
  }
} 