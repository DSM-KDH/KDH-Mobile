import 'package:kdh_mobile/core/config/app_env.dart';

class ApiEndpoint{
  /// baseUrl
  static const baseUrl = AppEnv.baseUrl;

  /// auth
  static const String authorizationGoogle = '/oauth2/authorization/google';
  static const String oauth2Failure = '/oauth2/failure';
  static const String oauth2LoginTest = '/oauth2/login-test';
  static const String oauth2Logout = '/oauth2/logout';
  static const String oauth2Success = '/oauth2/success';
  static const String oauth2Withdrawal = '/oauth2/withdrawal';

  /// routine
  static const String routines = '/routines';
  static const String routinesDates = '/routines/dates';
  static const String routinesAchievementLastWeek =
      '/routines/achievement-rate/last-week';
  static const String routinesAchievementWeeks =
      '/routines/achievement-rate/weeks';
  static String routineExerciseCompletion(int exerciseId) => '/routines/exercises/$exerciseId/completion';
  static String routineExercise(int exerciseId) =>
      '/routines/exercises/$exerciseId';

  /// user
  static const String userMe = '/users/me';
  static const String userProfile = '/users/me/profile';
  static const String userProfileHistory = '/users/me/profile/history';
}