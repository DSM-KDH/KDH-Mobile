import 'package:watch_connectivity/watch_connectivity.dart';

class WatchService {
  WatchService._();

  static final _wc = WatchConnectivity();

  static Future<void> sendAccessToken(String accessToken) async {
    try {
      final supported = await _wc.isSupported;
      if (!supported) return;

      final paired = await _wc.isPaired;
      if (!paired) return;

      final reachable = await _wc.isReachable;
      if (reachable) {
        await _wc.sendMessage({
          'action': 'setWatchAccessToken',
          'accessToken': accessToken,
        });
      } else {
        await _wc.updateApplicationContext({
          'action': 'setWatchAccessToken',
          'accessToken': accessToken,
        });
      }
    } catch (_) {}
  }

  static Future<void> clearToken() async {
    try {
      final supported = await _wc.isSupported;
      if (!supported) return;

      await _wc.updateApplicationContext({
        'action': 'setWatchAccessToken',
        'accessToken': '',
      });
    } catch (_) {}
  }
}
