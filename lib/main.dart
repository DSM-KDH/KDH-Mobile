import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: KdhColor.background,
        fontFamily: 'Pretendard',
      ),
      routerConfig: appRouter,
    );
  }
}
