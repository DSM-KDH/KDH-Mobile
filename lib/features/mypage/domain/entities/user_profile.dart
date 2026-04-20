enum Gender { male, female }

class UserProfile {
  const UserProfile({this.name = '하원', this.height, this.weight, this.gender});

  final String name;
  final double? height;
  final double? weight;
  final Gender? gender;

  bool get hasInfo => height != null || weight != null || gender != null;

  String get subtitle {
    if (!hasInfo) return '사용자 정보를 입력해주세요';
    final parts = <String>[];
    if (height != null) parts.add('${height}cm');
    if (weight != null) parts.add('${weight}kg');
    if (gender != null) parts.add(gender == Gender.male ? '남' : '여');
    return parts.join(' · ');
  }

  UserProfile copyWith({
    String? name,
    double? height,
    double? weight,
    Gender? gender,
  }) {
    return UserProfile(
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
    );
  }
}
