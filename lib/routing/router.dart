import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/main_tab.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/webview_screen.dart';
import '../features/call/model/hostpital.dart';
import '../features/call/presentation/call_screen.dart';
import '../features/hospital/presentation/hospital_detail_screen.dart';
import '../main.dart';

final router = GoRouter(
  navigatorKey: navigatorKey, // ✅ 이 부분 추가
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const MainTab()),
    GoRoute(path: '/main', builder: (context, state) => const MainTab()),
    GoRoute(path: '/call', builder: (context, state) => const CallScreen()),
    GoRoute(
      path: '/webview',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return WebViewScreen(
          url: params['url'] ?? '',
          title: params['title'] ?? '웹뷰',
        );
      },
    ),
    /// ✅ 병원 상세 화면 추가
    GoRoute(
      path: '/hospital-detail/:id/:createdAt',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final createdAt = int.parse(state.pathParameters['createdAt']!);
        final hospital = state.extra as Hospital;
        return HospitalDetailScreen(hospitalId: id, createdAt: createdAt, hospital: hospital);
      },
    ),
  ],
);
