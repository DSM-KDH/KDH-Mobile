import 'package:kdh_mobile/features/mypage/data/models/user_profile_model.dart';

abstract interface class UserProfileRepository {
  Future<UserProfileModel> fetchProfile();

  Future<UserProfileModel> saveProfile({
    required double heightCm,
    required double weightKg,
    required String gender,
  });

  Future<List<UserProfileModel>> fetchProfileHistory();
}
