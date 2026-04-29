/// JWT 토큰 인메모리 저장소.
/// 앱 재시작 시 초기화됨 — 영구 저장이 필요하면 flutter_secure_storage 연동 필요.
class TokenStorage {
  TokenStorage._();

  static String? _accessToken;
  static String? _refreshToken;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static bool get hasToken => _accessToken != null;

  static void save({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  static void clear() {
    _accessToken = null;
    _refreshToken = null;
  }
}
