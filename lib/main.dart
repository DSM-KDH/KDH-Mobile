import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/core/router/app_router.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';
import 'package:kdh_mobile/core/services/fcm_service.dart';
import 'package:kdh_mobile/core/services/timer_notification_service.dart';
import 'package:kdh_mobile/core/watch/watch_token_sync_service.dart';
import 'package:kdh_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.restore();
  runApp(const ProviderScope(child: MyApp()));
  unawaited(_initializeAppServices());
}

Future<void> _initializeAppServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FcmService.initialize();
    await TimerNotificationService.initialize();
    await TimerNotificationService.requestPermissions();
    await initBackgroundTimerService();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app initialization',
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final token = TokenStorage.accessToken;
      if (token != null && token.isNotEmpty) {
        unawaited(WatchTokenSyncService.syncAccessToken(token));
      }
    }
  }

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
