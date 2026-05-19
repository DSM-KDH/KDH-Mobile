import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccess  = 'access_token';
  static const _kRefresh = 'refresh_token';

  static String? _accessToken;
  static String? _refreshToken;

  static String? get accessToken  => _accessToken;
  static String? get refreshToken => _refreshToken;
  static bool   get hasToken      => _accessToken != null;

  static Future<void> restore() async {
    _accessToken  = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);
  }

  static void save({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken  = accessToken;
    _refreshToken = refreshToken;
    unawaited(_storage.write(key: _kAccess,  value: accessToken));
    unawaited(_storage.write(key: _kRefresh, value: refreshToken));
  }

  static void clear() {
    _accessToken  = null;
    _refreshToken = null;
    unawaited(_storage.deleteAll());
  }
}
