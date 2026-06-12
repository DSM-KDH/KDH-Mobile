import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/error/app_exception.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/core/services/watch_service.dart';
import 'package:kdh_mobile/core/watch/watch_token_sync_service.dart';
import 'package:kdh_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kdh_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kdh_mobile/features/auth/domain/repositories/auth_repository.dart';

final _authDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDataSourceProvider)),
);

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userEmail,
    this.error,
  });

  final bool isAuthenticated;
  final bool isLoading;

  final String? userEmail;
  final String? error;

  String get displayName {
    if (userEmail == null) return '회원';
    if (userEmail!.contains('@')) return userEmail!.split('@').first;
    return userEmail!;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userEmail,
    String? error,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    isLoading: isLoading ?? this.isLoading,
    userEmail: userEmail ?? this.userEmail,
    error: error,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository)
    : super(
        AuthState(
          isAuthenticated: TokenStorage.hasToken,
          userEmail: _extractEmailFromJwt(TokenStorage.accessToken ?? ''),
        ),
      ) {
    final existingToken = TokenStorage.accessToken;
    if (existingToken != null && existingToken.isNotEmpty) {
      unawaited(WatchTokenSyncService.syncAccessToken(existingToken));
    }
  }

  final AuthRepository _repository;

  String getGoogleAuthUrl() => _repository.getGoogleAuthUrl();

  void handleLoginSuccess(String accessToken, String refreshToken) {
    _repository.handleLoginSuccess(accessToken, refreshToken);

    final email = _extractEmailFromJwt(accessToken);

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userEmail: email,
    );

    unawaited(WatchTokenSyncService.syncAccessToken(accessToken));
  }

  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.logout();

      state = const AuthState(isAuthenticated: false);

      WatchService.clearToken();
      return true;
    } catch (e) {
      if (!TokenStorage.hasToken) {
        state = const AuthState(isAuthenticated: false);
        WatchService.clearToken();
        return true;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> withdrawal() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.withdrawal();

      state = const AuthState(isAuthenticated: false);
      WatchService.clearToken();
      return true;
    } catch (e) {
      if (!TokenStorage.hasToken) {
        state = const AuthState(isAuthenticated: false);
        WatchService.clearToken();
        return true;
      }
      state = state.copyWith(isLoading: false, error: _readableError(e));
      return false;
    }
  }

  String _readableError(Object e) {
    if (e is AppException) return e.message;
    return '회원탈퇴에 실패했습니다. 잠시 후 다시 시도해주세요.';
  }

  static String? _extractEmailFromJwt(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) return null;

      final payload = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(payload));

      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return (json['email'] ?? json['name']) as String?;
    } catch (_) {
      return null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(_authRepositoryProvider)),
);
