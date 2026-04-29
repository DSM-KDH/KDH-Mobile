import 'package:dio/dio.dart';
import 'package:kdh_mobile/core/network/api_endpoint.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/mypage/data/models/user_profile_model.dart';
import 'package:kdh_mobile/features/mypage/data/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfileModel> fetchProfile() async {
    try {
      final response = await _dio.get(ApiEndpoint.userProfile);
      return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<UserProfileModel> saveProfile({
    required double heightCm,
    required double weightKg,
    required String gender,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoint.userProfile,
        data: {'heightCm': heightCm, 'weightKg': weightKg, 'gender': gender},
      );
      return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<List<UserProfileModel>> fetchProfileHistory() async {
    try {
      final response = await _dio.get(ApiEndpoint.userProfileHistory);
      return (response.data as List)
          .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }
}
