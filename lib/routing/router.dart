import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/main_tab.dart';
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
      path: '/main', // ✅ 반드시 이게 있어야 합니다!
      builder: (context, state) => const MainTab(),
    ),
    GoRoute(
      path: '/call',
      builder: (context, state) => const CallScreen(),
    ),
  ],
);
