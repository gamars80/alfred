import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/id_password_login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/main_tab.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/webview_screen.dart';
import '../features/call/model/hostpital.dart';
import '../features/call/presentation/call_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/guided_chat_screen.dart';
import '../features/hospital/presentation/hospital_detail_screen.dart';
import '../features/mypage/presentation/mypage_screen.dart';
import '../features/mypage/presentation/settings_screen.dart';
import '../features/mypage/presentation/command_authority_history_screen.dart';
import '../main.dart';

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    // Handle kakao oauth redirect
    if (state.uri.toString().startsWith('kakao')) {
      final code = state.uri.queryParameters['code'];
      if (code != null) {
        return '/login?code=$code';
      }
    }
    return null;
  },
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
    GoRoute(
      path: '/history',
      builder: (context, state) => MainTab(selectedIndex: 1),
    ),
            GoRoute(
          path: '/history/beauty',
          builder: (context, state) => MainTab(selectedIndex: 1, selectedBeautyTab: 1),
        ),
        GoRoute(
          path: '/history/food',
          builder: (context, state) => MainTab(selectedIndex: 1, selectedFoodTab: 2),
        ),
        GoRoute(
          path: '/history/beauty-care',
          builder: (context, state) => MainTab(selectedIndex: 1, selectedBeautyCareTab: 3),
        ),
    GoRoute(path: '/call', builder: (context, state) => const CallScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/guided-chat', builder: (context, state) => const GuidedChatScreen()),
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
    GoRoute(
      path: '/mypage',
      builder: (context, state) => const MyPageScreen(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'command-authority-history',
          builder: (context, state) => const CommandAuthorityHistoryScreen(),
        ),
      ],
    ),
  ],
);
