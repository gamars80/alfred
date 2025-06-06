import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/id_password_login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/main_tab.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/webview_screen.dart';
import '../features/call/model/hostpital.dart';
import '../features/call/presentation/call_screen.dart';
import '../features/hospital/presentation/hospital_detail_screen.dart';
import '../features/mypage/presentation/mypage_screen.dart';
import '../features/mypage/presentation/settings_screen.dart';
import '../main.dart';

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/id-password-login', builder: (context, state) => const IdPasswordLoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const MainTab()),
    GoRoute(
      path: '/main',
      builder: (context, state) => MainTab(selectedIndex: 2),
    ),
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
    GoRoute(
      path: '/hospital-detail/:id/:createdAt',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final createdAt = int.parse(state.pathParameters['createdAt']!);
        final hospital = state.extra as Hospital;
        return HospitalDetailScreen(
          hospitalId: id,
          createdAt: createdAt,
          hospital: hospital,
        );
      },
    ),
    GoRoute(path: '/mypage', builder: (context, state) => const MyPageScreen()),
    GoRoute(path: '/mypage/settings', builder: (context, state) => SettingsScreen()),
  ],
);
