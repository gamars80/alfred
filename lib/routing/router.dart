import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/main_tab.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/webview_screen.dart';
import '../features/call/presentation/call_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainTab(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainTab(),
    ),
    GoRoute(
      path: '/call',
      builder: (context, state) => const CallScreen(),
    ),
    GoRoute(
      path: '/webview',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final url = params['url'] ?? '';
        final title = params['title'] ?? '웹뷰';
        return WebViewScreen(url: url, title: title);
      },
    ),
  ],
);