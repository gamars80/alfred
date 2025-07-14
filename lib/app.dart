import 'package:alfred_clean/routing/router.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/kakao_callback_screen.dart';

class AlfredApp extends StatelessWidget {
  const AlfredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alfred',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}


