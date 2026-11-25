import 'package:extinction_sanctuary/core/format/game_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameFormat.compact unit boundaries', () {
    test('keeps whole numbers below one thousand', () {
      expect(GameFormat.compact(0), '0');
      expect(GameFormat.compact(999), '999');
    });

    test('promotes to the k unit at one thousand', () {
      expect(GameFormat.compact(1000), '1.0k');
    });

    test('stays in k while one decimal still fits', () {
      expect(GameFormat.compact(999949), '999.9k');
    });

    test('promotes to M instead of printing 1000.0k at 999950', () {
      expect(GameFormat.compact(999950), '1.00M');
    });

    test('promotes to M at 999999', () {
      expect(GameFormat.compact(999999), '1.00M');
    });

    test('keeps M for one million and above', () {
      expect(GameFormat.compact(1000000), '1.00M');
      expect(GameFormat.compact(1234567), '1.23M');
    });

    test('promotes to B instead of printing 1000.00M near a billion', () {
      expect(GameFormat.compact(999999999), '1.00B');
    });

    test('uses B at one billion', () {
      expect(GameFormat.compact(1000000000), '1.00B');
    });

    test('applies the same thresholds to negative values', () {
      expect(GameFormat.compact(-999999), '-1.00M');
    });
  });

  group('GameFormat.rate sign', () {
    test('prefixes gains with a plus', () {
      expect(GameFormat.rate(22.5), '+22.5/s');
    });

    test('prints zero without a sign', () {
      expect(GameFormat.rate(0), '0.0/s');
    });

    test('prints losses with their own minus sign only', () {
      expect(GameFormat.rate(-1), '-1.0/s');
    });
  });
}
