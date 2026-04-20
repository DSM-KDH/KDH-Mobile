import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/weight_entry.dart';

final weightHistoryProvider =
    NotifierProvider<WeightHistoryNotifier, List<WeightEntry>>(
      WeightHistoryNotifier.new,
    );

class WeightHistoryNotifier extends Notifier<List<WeightEntry>> {
  @override
  List<WeightEntry> build() => [
    WeightEntry(date: DateTime(2026, 1, 5), weight: 67),
    WeightEntry(date: DateTime(2026, 1, 20), weight: 66),
    WeightEntry(date: DateTime(2026, 2, 8), weight: 65.5),
    WeightEntry(date: DateTime(2026, 2, 22), weight: 65),
    WeightEntry(date: DateTime(2026, 3, 10), weight: 63.5),
    WeightEntry(date: DateTime(2026, 3, 25), weight: 63),
    WeightEntry(date: DateTime(2026, 4, 5), weight: 61.5),
    WeightEntry(date: DateTime(2026, 4, 18), weight: 61),
  ];

  void addEntry(WeightEntry entry) {
    state = [...state, entry];
  }
}
