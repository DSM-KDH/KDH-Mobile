import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/core/network/token_storage.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:kdh_mobile/features/mypage/data/repositories/user_profile_repository.dart';
import 'package:kdh_mobile/features/mypage/data/repositories/user_profile_repository_impl.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/user_profile.dart';

final _userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepositoryImpl(ref.watch(dioProvider)),
);

class UserProfileState {
  const UserProfileState({
    this.profile = const UserProfile(),
    this.isLoading = false,
    this.error,
  });

  final UserProfile profile;
  final bool isLoading;
  final String? error;

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) => UserProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier(this._ref, this._repository)
    : super(const UserProfileState()) {
    if (TokenStorage.hasToken) loadProfile();

    _ref.listen<AuthState>(authProvider, (prev, next) {
      final justLoggedIn = !(prev?.isAuthenticated ?? false) && next.isAuthenticated;
      if (justLoggedIn) loadProfile();
    });
  }

  final Ref _ref;
  final UserProfileRepository _repository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final model = await _repository.fetchProfile();
      state = state.copyWith(profile: model.toDomain(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveProfile({
    required double height,
    required double weight,
    required Gender gender,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final model = await _repository.saveProfile(
        heightCm: height,
        weightKg: weight,
        gender: gender == Gender.male ? 'MALE' : 'FEMALE',
      );
      state = state.copyWith(profile: model.toDomain(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
      (ref) => UserProfileNotifier(ref, ref.watch(_userProfileRepositoryProvider)),
    );
