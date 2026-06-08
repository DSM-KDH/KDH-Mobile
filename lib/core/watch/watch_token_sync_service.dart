import 'dart:async';

import 'package:watch_connectivity/watch_connectivity.dart';

class WatchTokenSyncService {
  WatchTokenSyncService._();

  static final WatchConnectivity _watch = WatchConnectivity();

  static const int _maxAttempts = 8;
  static const Duration _retryDelay = Duration(milliseconds: 600);

  static Completer<void>? _inFlight;

  static Future<void> syncAccessToken(String accessToken) =>
      _sendWithRetry(accessToken);

  static Future<void> clearToken() => _sendWithRetry('');

  static Future<void> _sendWithRetry(String accessToken) async {
    final previous = _inFlight;
    if (previous != null) {
      try {
        await previous.future;
      } catch (_) {}
    }
    final completer = Completer<void>();
    _inFlight = completer;

    try {
      try {
        if (!await _watch.isSupported) {
          _log('not supported on this device');
          return;
        }
      } catch (e) {
        _log('isSupported check failed: $e');
        return;
      }

      for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
        if (await _trySend(accessToken, attempt)) return;
        await Future<void>.delayed(_retryDelay);
      }
      _log('gave up after $_maxAttempts attempts');
    } finally {
      if (identical(_inFlight, completer)) _inFlight = null;
      completer.complete();
    }
  }

  static Future<bool> _trySend(String accessToken, int attempt) async {
    final payload = <String, dynamic>{
      'action': 'setWatchAccessToken',
      'accessToken': accessToken,
      'syncedAt': DateTime.now().microsecondsSinceEpoch,
    };

    try {
      final paired = await _watch.isPaired;
      if (!paired) {
        _log('attempt $attempt: not paired/activated yet — retrying');
        return false;
      }

      var reachable = false;
      try {
        reachable = await _watch.isReachable;
      } catch (_) {}
      if (reachable) {
        try {
          await _watch.sendMessage(payload);
          _log('attempt $attempt: sendMessage ok');
        } catch (e) {
          _log('attempt $attempt: sendMessage failed: $e');
        }
      }

      await _watch.updateApplicationContext(payload);
      _log('attempt $attempt: updateApplicationContext ok (reachable=$reachable)');
      return true;
    } catch (e) {
      _log('attempt $attempt: failed ($e) — retrying');
      return false;
    }
  }

  static void _log(String message) {
    // ignore: avoid_print
    print('[WatchConnectivity][iPhone] $message');
  }
}
