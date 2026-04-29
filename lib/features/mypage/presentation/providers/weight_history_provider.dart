import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/mypage/data/repositories/user_profile_repository.dart';
import 'package:kdh_mobile/features/mypage/data/repositories/user_profile_repository_impl.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/weight_entry.dart';

final _weightRepoProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepositoryImpl(ref.watch(dioProvider)),
);

class WeightHistoryNotifier extends StateNotifier<List<WeightEntry>> {
  WeightHistoryNotifier(this._repository) : super([]);

  final UserProfileRepository _repository;

  Future<void> loadHistory() async {
    try {
      final history = await _repository.fetchProfileHistory();
      state = history.map((m) => m.toWeightEntry()).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {}
  }
}

final weightHistoryProvider =
    StateNotifierProvider<WeightHistoryNotifier, List<WeightEntry>>(
      (ref) => WeightHistoryNotifier(ref.watch(_weightRepoProvider)),
    );
