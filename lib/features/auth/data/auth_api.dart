import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../common/dio/dio_client.dart';
import '../model/login_response.dart';
import '../model/signup_response.dart';
import 'device_info_service.dart';


class AuthApi {
  static final Dio _dio = DioClient.dio;

  static Future<LoginResponse> loginWithKakaoId(String loginId) async {
    debugPrint("loginId::::::::::::::::$loginId");
    final response = await _dio.post('/auth/login', data: {'loginId': loginId});
    return LoginResponse.fromJson(response.data);
  }

  static Future<LoginResponse> loginWithIdPassword({
    required String loginId,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'loginId': loginId,
      'password': password,
      'loginType': 'NORMAL',
    });
    return LoginResponse.fromJson(response.data);
  }

  static Future<LoginResponse> loginWithAppleId(String loginId) async {
    debugPrint("Apple loginId::::::::::::::::$loginId");
    final response = await _dio.post('/auth/login', data: {'loginId': loginId});
    return LoginResponse.fromJson(response.data);
  }

  static Future<SignupResponse> registerKakaoUser({
    required String loginId,
    required String email,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // 디바이스 정보 가져오기
      final deviceInfo = await DeviceInfoService.getAllDeviceInfo();
      
      final payload = {
        'loginId': loginId,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'joinType': 'KAKAO',
        'deviceUniqueId': deviceInfo['deviceUniqueId'],
        'osType': deviceInfo['osType'],
        'appVersion': deviceInfo['appVersion'],
        'devicePushToken': deviceInfo['devicePushToken'],
      };
      
      debugPrint("카카오 회원가입 페이로드: $payload");
      
      final response = await _dio.post('/auth/signup', data: payload);

      return SignupResponse.fromJson(response.data);
    } catch (e) {
      debugPrint("카카오 회원가입 에러: $e");
      debugPrint("카카오 회원가입 에러 타입: ${e.runtimeType}");
      
      // 백엔드에서 보내는 에러 메시지를 그대로 토스트로 표시
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        debugPrint("응답 데이터 타입: ${responseData.runtimeType}");
        debugPrint("응답 데이터 내용: $responseData");
        
        // response.data가 문자열인 경우
        if (responseData is String) {
          Fluttertoast.showToast(
            msg: responseData,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
        // response.data가 Map인 경우 (JSON 형태)
        else if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
      }
      
      // 기존 방식도 유지 (fallback)
      if (e.toString().contains('디바이스가 차단') || e.toString().contains('탈퇴한적이 있어서')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
      
      rethrow;
    }
  }

  static Future<SignupResponse> registerNormalUser({
    required String loginId,
    required String password,
  }) async {
    try {
      // 디바이스 정보 가져오기
      final deviceInfo = await DeviceInfoService.getAllDeviceInfo();
      
      final payload = {
        'loginId': loginId,
        'password': password,
        'email': '',
        'name': '',
        'phoneNumber': '',
        'joinType': 'NORMAL',
        'deviceUniqueId': deviceInfo['deviceUniqueId'],
        'osType': deviceInfo['osType'],
        'appVersion': deviceInfo['appVersion'],
        'devicePushToken': deviceInfo['devicePushToken'],
      };
      
      debugPrint("일반 회원가입 페이로드: $payload");
      
      final response = await _dio.post('/auth/signup', data: payload);

      return SignupResponse.fromJson(response.data);
    } catch (e) {
      debugPrint("일반 회원가입 에러: $e");
      debugPrint("일반 회원가입 에러 타입: ${e.runtimeType}");
      
      // 백엔드에서 보내는 에러 메시지를 그대로 토스트로 표시
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        debugPrint("응답 데이터 타입: ${responseData.runtimeType}");
        debugPrint("응답 데이터 내용: $responseData");
        
        // response.data가 문자열인 경우
        if (responseData is String) {
          Fluttertoast.showToast(
            msg: responseData,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
        // response.data가 Map인 경우 (JSON 형태)
        else if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
      }
      
      // 기존 방식도 유지 (fallback)
      if (e.toString().contains('디바이스가 차단') || e.toString().contains('탈퇴한적이 있어서')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
      
      rethrow;
    }
  }

  static Future<SignupResponse> registerAppleUser({
    required String loginId,
    required String email,
    required String name,
  }) async {
    try {
      // 디바이스 정보 가져오기
      final deviceInfo = await DeviceInfoService.getAllDeviceInfo();
      
      final payload = {
        'loginId': loginId,
        'email': email,
        'name': name,
        'phoneNumber': '',
        'joinType': 'APPLE',
        'deviceUniqueId': deviceInfo['deviceUniqueId'],
        'osType': deviceInfo['osType'],
        'appVersion': deviceInfo['appVersion'],
        'devicePushToken': deviceInfo['devicePushToken'],
      };
      
      debugPrint("애플 회원가입 페이로드: $payload");
      
      final response = await _dio.post('/auth/signup', data: payload);

      return SignupResponse.fromJson(response.data);
    } catch (e) {
      debugPrint("애플 회원가입 에러: $e");
      debugPrint("애플 회원가입 에러 타입: ${e.runtimeType}");
      
      // 백엔드에서 보내는 에러 메시지를 그대로 토스트로 표시
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        debugPrint("응답 데이터 타입: ${responseData.runtimeType}");
        debugPrint("응답 데이터 내용: $responseData");
        
        // response.data가 문자열인 경우
        if (responseData is String) {
          Fluttertoast.showToast(
            msg: responseData,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
        // response.data가 Map인 경우 (JSON 형태)
        else if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
      }
      
      // 기존 방식도 유지 (fallback)
      if (e.toString().contains('디바이스가 차단') || e.toString().contains('탈퇴한적이 있어서')) {
        Fluttertoast.showToast(
          msg: '이 디바이스는 차단되어 있습니다. 차단 기간이 끝난 후 다시 시도해주세요.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
      
      rethrow;
    }
  }
}
