import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

  static Future<SignupResponse> registerKakaoUser({
    required String loginId,
    required String email,
    required String name,
    required String phoneNumber,
  }) async {
    final response = await _dio.post('/auth/signup', data: {
      'loginId': loginId,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'joinType': 'KAKAO',
    });

    // 회원가입 성공 후 디바이스 등록 비동기 호출
    DeviceInfoService.getAllDeviceInfo().then((deviceInfo) {
      _dio.post('/api/user/device', data: deviceInfo).catchError((e) {
        // 에러 무시
      });
    });

    return SignupResponse.fromJson(response.data);
  }

  static Future<SignupResponse> registerNormalUser({
    required String loginId,
    required String password,
  }) async {
    final response = await _dio.post('/auth/signup', data: {
      'loginId': loginId,
      'password': password,
      'email': '',
      'name': '',
      'phoneNumber': '',
      'joinType': 'NORMAL',
    });

    // 회원가입 성공 후 디바이스 등록 비동기 호출
    DeviceInfoService.getAllDeviceInfo().then((deviceInfo) {
      _dio.post('/api/user/device', data: deviceInfo).catchError((e) {
        // 에러 무시
      });
    });

    return SignupResponse.fromJson(response.data);
  }
}
