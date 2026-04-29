import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/config/app_env.dart';
import 'package:kdh_mobile/core/error/app_exception.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )
    ..interceptors.add(_AuthInterceptor())
    ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});

/// Authorization 헤더 자동 주입 + 에러 → 도메인 예외 변환
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    AppException mapped;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      mapped = const NetworkException();
    } else if (statusCode == 401) {
      TokenStorage.clear();
      mapped = const UnauthorizedException();
    } else if (statusCode != null && statusCode >= 500) {
      mapped = const ServerException();
    } else {
      final msg = err.response?.data?['message'] as String?;
      mapped = AppException(msg ?? err.message ?? '알 수 없는 오류가 발생했습니다.');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: mapped,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

/// DioException에서 AppException을 꺼내는 헬퍼
AppException extractAppException(DioException e) =>
    e.error is AppException ? e.error as AppException : AppException(e.message ?? '오류');
