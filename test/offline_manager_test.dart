import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/core/offline/offline_manager.dart';
import 'package:extinction_sanctuary/models/game_state.dart';

void main() {
  group('OfflineManager Tests', () {
    const offlineManager = OfflineManager();

    test('Ignores small offline intervals under 15 seconds', () {
      final state = GameState.initial();
      final now = state.lastSavedTimestamp + 5000; // 5 seconds later
      final report = offlineManager.calculateOfflineProgress(
        state: state,
        currentTimestampMs: now,
      );

      expect(report, isNull);
    });

    test('Formats a report shorter than a minute in seconds', () {
      final state = GameState.initial();
      final now = state.lastSavedTimestamp + 30000; // 30 seconds later

      final report = offlineManager.calculateOfflineProgress(
        state: state,
        currentTimestampMs: now,
      );

      expect(report, isNotNull);
      // "0m" read as no time at all right above a list of earnings.
      expect(report!.awayDurationFormatted, equals('30s'));
    });

    test(
      'Calculates offline progress deterministically for 30 minutes away',
      () {
        final state = GameState.initial();
        const halfHourMs = 30 * 60 * 1000;
        final now = state.lastSavedTimestamp + halfHourMs;

        final report = offlineManager.calculateOfflineProgress(
          state: state,
          currentTimestampMs: now,
        );

        expect(report, isNotNull);
        expect(report!.wasCapped, isFalse);
        expect(report.secondsAway, equals(1800.0));
        expect(report.simulatedSeconds, equals(1800.0));
        expect(report.creditsEarned, greaterThan(100.0));
        expect(report.dnaRecovered, greaterThan(20.0));
        expect(report.dodosBorn, greaterThanOrEqualTo(1));
        expect(report.awayDurationFormatted, equals('30m'));
      },
    );

    test('Truncates offline progress at configured offline cap', () {
      final state = GameState.initial(); // cap = 7200s (2 hours)
      const fiveHoursMs = 5 * 60 * 60 * 1000;
      final now = state.lastSavedTimestamp + fiveHoursMs;

      final report = offlineManager.calculateOfflineProgress(
        state: state,
        currentTimestampMs: now,
      );

      expect(report, isNotNull);
      expect(report!.wasCapped, isTrue);
      expect(report.secondsAway, equals(5 * 3600.0));
      expect(report.simulatedSeconds, equals(state.offlineCapSeconds));
      expect(report.awayDurationFormatted, equals('5h 0m'));
    });
  });
}
