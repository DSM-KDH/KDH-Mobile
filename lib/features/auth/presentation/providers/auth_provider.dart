import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kdh_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kdh_mobile/features/auth/domain/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// DI providers
// ---------------------------------------------------------------------------

final _authDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDataSourceProvider)),
);

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userEmail,
    this.error,
  });

  final bool isAuthenticated;
  final bool isLoading;

  /// JWT에서 파싱한 이메일 (로그인 후 채워짐)
  final String? userEmail;
  final String? error;

  /// 화면에 표시할 이름 — 이메일의 @ 앞부분, 없으면 '회원'
  String get displayName {
    if (userEmail == null) return '회원';
    return userEmail!.split('@').first;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userEmail,
    String? error,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        userEmail: userEmail ?? this.userEmail,
        error: error,
      );
}

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository)
      : super(AuthState(isAuthenticated: TokenStorage.hasToken));

  final AuthRepository _repository;

  /// WebView / 브라우저에서 열어야 할 Google OAuth2 URL 반환
  String getGoogleAuthUrl() => _repository.getGoogleAuthUrl();

  /// OAuth2 성공 콜백에서 accessToken, refreshToken 저장
  /// JWT 페이로드에서 이메일을 파싱해 displayName으로 사용
  void handleLoginSuccess(String accessToken, String refreshToken) {
    _repository.handleLoginSuccess(accessToken, refreshToken);
    final email = _extractEmailFromJwt(accessToken);
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userEmail: email,
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 회원 탈퇴
  Future<void> withdrawal() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.withdrawal();
      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── JWT 파싱 헬퍼 ────────────────────────────────────────────────────────

  static String? _extractEmailFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      // base64url → base64 정규화
      final payload = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['email'] as String?;
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(_authRepositoryProvider)),
);
