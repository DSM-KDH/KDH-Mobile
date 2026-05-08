import 'package:kdh_mobile/features/mypage/domain/entities/user_profile.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/weight_entry.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.recordedAt,
    this.nextReminderAt,
  });

  final int id;
  final String name;
  final double heightCm;
  final double weightKg;
  final String gender;
  final DateTime recordedAt;
  final DateTime? nextReminderAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        gender: json['gender'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        nextReminderAt: json['nextReminderAt'] != null
            ? DateTime.parse(json['nextReminderAt'] as String)
            : null,
      );

  Map<String, dynamic> toRequestJson() => {
    'heightCm': heightCm,
    'weightKg': weightKg,
    'gender': gender,
  };

  UserProfile toDomain() => UserProfile(
    name: name,
    height: heightCm,
    weight: weightKg,
    gender: gender == 'MALE' ? Gender.male : Gender.female,
  );

  WeightEntry toWeightEntry() =>
      WeightEntry(date: recordedAt, weight: weightKg);
}
