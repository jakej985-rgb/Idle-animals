/// Centralises player-facing number formatting so the header, sheets and
/// modals all use the same abbreviations and precision.
abstract final class GameFormat {
  static String compact(double value) {
    final magnitude = value.abs();
    // Thresholds sit where rounding would otherwise print a mantissa of 1000
    // (e.g. 999999 used to render as "1000.0k" instead of "1.00M").
    if (magnitude >= 999995000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (magnitude >= 999950) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (magnitude >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  static String whole(double value) => value.toStringAsFixed(0);

  static String decimal(double value) => value.toStringAsFixed(1);

  /// Signed per-second rate. Only gains carry a "+"; zero and losses already
  /// read correctly ("0.0/s", "-1.0/s") instead of "+0.0/s" and "+-1.0/s".
  static String rate(double value) {
    final formatted = value.toStringAsFixed(1);
    return value > 0 ? '+$formatted/s' : '$formatted/s';
  }
}
