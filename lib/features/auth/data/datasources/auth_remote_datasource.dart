import 'package:dio/dio.dart';
import 'package:kdh_mobile/core/config/app_env.dart';
import 'package:kdh_mobile/core/error/app_exception.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/core/network/api_endpoint.dart';
import 'package:kdh_mobile/features/auth/data/models/auth_token_model.dart';

abstract interface class AuthRemoteDataSource {
  String getGoogleAuthUrl();

  AuthTokenModel parseSuccessCallback(Map<String, String> queryParams);

  Future<void> logout();

  Future<void> withdrawal();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  String getGoogleAuthUrl() =>
      '${AppEnv.baseUrl.replaceAll(RegExp(r'/$'), '')}${ApiEndpoint.authorizationGoogle}';

  @override
  AuthTokenModel parseSuccessCallback(Map<String, String> queryParams) {
    final accessToken = queryParams['accessToken'];
    final refreshToken = queryParams['refreshToken'];
    if (accessToken == null || refreshToken == null) {
      throw const AppException('OAuth2 콜백에 토큰이 없습니다.');
    }
    return AuthTokenModel(
      success: true,
      message: '로그인 성공',
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoint.oauth2Logout);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<void> withdrawal() async {
    try {
      await _dio.post(ApiEndpoint.oauth2Withdrawal);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }
}
