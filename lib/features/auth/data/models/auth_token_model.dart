class AuthTokenModel {
  const AuthTokenModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
    success: json['success'] as bool,
    message: json['message'] as String,
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
