import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 무조건 제일 먼저 호출

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '22e6b88148da0c4cb1293cbe664cecc4',
  );

  await dotenv.load();
  runApp(const AlfredApp());
}