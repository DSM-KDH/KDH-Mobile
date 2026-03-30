import 'package:kdh_mobile/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  const SignInWithGoogleUseCase(this._repository);

  Future<void> call() => _repository.signInWithGoogle();
}
