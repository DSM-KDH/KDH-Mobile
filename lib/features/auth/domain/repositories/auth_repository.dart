abstract interface class AuthRepository {
  String getGoogleAuthUrl();
  void handleLoginSuccess(String accessToken, String refreshToken);
  Future<void> logout();
  Future<void> withdrawal();
}
