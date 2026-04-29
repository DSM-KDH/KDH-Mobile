class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = '네트워크 오류가 발생했습니다.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = '인증이 만료되었습니다. 다시 로그인해주세요.']);
}

class ServerException extends AppException {
  const ServerException([super.message = '서버 오류가 발생했습니다.']);
}
