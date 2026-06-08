class ActiveTimerRegistry {
  ActiveTimerRegistry._();

  static String? _activeKey;

  static String? get activeKey => _activeKey;

  static bool get hasActive => _activeKey != null;

  static bool isActive(String key) => _activeKey == key;

  static bool isBlockedFor(String key) =>
      _activeKey != null && _activeKey != key;

  static void setActive(String key) => _activeKey = key;

  static void clear() => _activeKey = null;

  static String intervalKey(int totalSeconds) => 'interval:$totalSeconds';
  static String customKey(int totalSeconds, List<int> intervals) =>
      'custom:$totalSeconds:${intervals.join(",")}';
  static String metronomeKey(int totalSeconds, int bpm) =>
      'metronome:$totalSeconds@$bpm';
}
