import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kdh_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  String getGoogleAuthUrl() => _dataSource.getGoogleAuthUrl();

  @override
  void handleLoginSuccess(String accessToken, String refreshToken) {
    TokenStorage.save(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
    TokenStorage.clear();
  }

  @override
  Future<void> withdrawal() async {
    await _dataSource.withdrawal();
    TokenStorage.clear();
  }
}
