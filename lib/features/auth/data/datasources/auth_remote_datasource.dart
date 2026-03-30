abstract interface class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
  }
}
