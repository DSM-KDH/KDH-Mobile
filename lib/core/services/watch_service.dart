import 'package:kdh_mobile/core/watch/watch_token_sync_service.dart';

class WatchService {
  WatchService._();

  static Future<void> sendAccessToken(String accessToken) =>
      WatchTokenSyncService.syncAccessToken(accessToken);

  static Future<void> clearToken() => WatchTokenSyncService.clearToken();
}
