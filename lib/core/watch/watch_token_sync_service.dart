import 'package:watch_connectivity/watch_connectivity.dart';

class WatchTokenSyncService {
  WatchTokenSyncService._();

  static final WatchConnectivity _watch = WatchConnectivity();

  static Future<void> syncAccessToken(String accessToken) async {
    final payload = <String, dynamic>{
      'action': 'setWatchAccessToken',
      'accessToken': accessToken,
      // Force context change so watchOS receives every sync attempt.
      'syncedAt': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      final isSupported = await _watch.isSupported;
      final isPaired = await _watch.isPaired;
      final isReachable = await _watch.isReachable;
      // ignore: avoid_print
      print(
        '[WatchConnectivity][iPhone] supported=$isSupported paired=$isPaired reachable=$isReachable',
      );
      if (!isSupported || !isPaired) return;

      if (isReachable) {
        await _watch.sendMessage(payload);
        // ignore: avoid_print
        print('[WatchConnectivity][iPhone] sendMessage sent');
      }

      await _watch.updateApplicationContext(payload);
      // ignore: avoid_print
      print('[WatchConnectivity][iPhone] updateApplicationContext updated');
    } catch (e) {
      // ignore: avoid_print
      print('[WatchConnectivity][iPhone] token sync failed: $e');
    }
  }
}
