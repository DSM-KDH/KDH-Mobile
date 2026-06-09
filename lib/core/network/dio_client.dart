import 'dart:developer' as dev;

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
    ..interceptors.add(_DevLogInterceptor());

  return dio;
});

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
      final data = err.response?.data;
      String? msg;
      if (data is Map) {
        msg = (data['description'] ?? data['message']) as String?;
      }
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

AppException extractAppException(DioException e) =>
    e.error is AppException ? e.error as AppException : AppException(e.message ?? '오류');

class _DevLogInterceptor extends Interceptor {
  static const _tag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = options.headers['Authorization'] as String?;
    final tokenSuffix =
        token != null ? '...${token.substring(token.length > 20 ? token.length - 10 : 0)}' : 'none';
    dev.log(
      '[REQ] ${options.method} ${options.uri}\n'
      '  body: ${options.data}\n'
      '  token: $tokenSuffix',
      name: _tag,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log(
      '[RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      '  body: ${response.data}',
      name: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log(
      '[ERR] ${err.response?.statusCode ?? err.type} ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '  response: ${err.response?.data}\n'
      '  message: ${err.message}',
      name: _tag,
      level: 900,
    );
    handler.next(err);
  }
}
