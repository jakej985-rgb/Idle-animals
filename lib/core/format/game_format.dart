/// Centralises player-facing number formatting so the header, sheets and
/// modals all use the same abbreviations and precision.
abstract final class GameFormat {
  static String compact(double value) {
    final magnitude = value.abs();
    if (magnitude >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (magnitude >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (magnitude >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  static String whole(double value) => value.toStringAsFixed(0);

  static String decimal(double value) => value.toStringAsFixed(1);

  static String rate(double value) => '+${value.toStringAsFixed(1)}/s';
}
