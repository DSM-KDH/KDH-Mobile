import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/core/router/app_router.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';
import 'package:kdh_mobile/core/services/timer_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.restore();
  await TimerNotificationService.initialize();
  await TimerNotificationService.requestPermissions();
  await initBackgroundTimerService();
  runApp(const ProviderScope(child: MyApp()));
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
