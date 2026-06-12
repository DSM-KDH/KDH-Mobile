import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:kdh_mobile/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _cachedToken;

  static String? get token => _cachedToken;

  static Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  static Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _cachedToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('[FCM] token: $_cachedToken');
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _cachedToken = newToken;
        if (kDebugMode) {
          debugPrint('[FCM] token refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] initialize failed: $e');
      }
    }
  }

  static Future<String?> ensureToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      _cachedToken = await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] ensureToken failed: $e');
      }
    }
    return _cachedToken;
  }
}
