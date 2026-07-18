/// Canonical Game Duration presets used by every TinyThink game.
abstract final class GameDuration {
  static const int defaultSeconds = 60;

  /// Child-friendly snap points (minutes → seconds).
  static const List<int> presetSeconds = [
    60, // 1
    120, // 2
    180, // 3
    300, // 5
    600, // 10
    900, // 15
    1200, // 20
    1500, // 25
    1800, // 30
  ];

  static const List<int> presetMinutes = [1, 2, 3, 5, 10, 15, 20, 25, 30];

  static int snap(int seconds) {
    if (seconds <= 0) return defaultSeconds;
    var best = presetSeconds.first;
    var bestDelta = (seconds - best).abs();
    for (final p in presetSeconds) {
      final d = (seconds - p).abs();
      if (d < bestDelta) {
        best = p;
        bestDelta = d;
      }
    }
    return best;
  }

  static int indexOf(int seconds) {
    final snapped = snap(seconds);
    final i = presetSeconds.indexOf(snapped);
    return i < 0 ? 0 : i;
  }

  static String label(int seconds) {
    final m = snap(seconds) ~/ 60;
    return m == 1 ? '1 min' : '$m min';
  }

  static String shortLabel(int seconds) {
    final m = snap(seconds) ~/ 60;
    return '${m}m';
  }
}
