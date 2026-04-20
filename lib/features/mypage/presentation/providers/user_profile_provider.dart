import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/user_profile.dart';

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => const UserProfile();

  void update({double? height, double? weight, Gender? gender}) {
    state = UserProfile(
      name: state.name,
      height: height ?? state.height,
      weight: weight ?? state.weight,
      gender: gender ?? state.gender,
    );
  }
}
