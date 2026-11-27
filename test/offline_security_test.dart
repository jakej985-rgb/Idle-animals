import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/core/offline/offline_manager.dart';
import 'package:extinction_sanctuary/models/game_state.dart';

void main() {
  group('Offline Security & Anti-Cheat Tests', () {
    const manager = OfflineManager();

    test('Rejects negative elapsed time when device clock is turned back', () {
      final initial = GameState.initial();
      final futureSavedTimeMs = 1700005000000;
      final currentClientTimeMs = 1700000000000; // in the past

      final stateWithFutureTime = initial.copyWith(
        lastSavedTimestamp: futureSavedTimeMs,
      );
      final report = manager.calculateOfflineProgress(
        state: stateWithFutureTime,
        currentTimestampMs: currentClientTimeMs,
      );

      // Report should be null (negative elapsed time completely rejected)
      expect(report, isNull);
    });

    test(
      'Clamps absurdly large clock jumps forward to safety threshold and cap',
      () {
        final initial = GameState.initial();
        final baseTimeMs = 1700000000000;
        // 2 years into the future (over 60 million seconds)
        final twoYearsLaterMs = baseTimeMs + (86400 * 365 * 2 * 1000);

        final savedState = initial.copyWith(
          lastSavedTimestamp: baseTimeMs,
          offlineCapSeconds: 86400, // 24-hour player offline cap
        );

        final report = manager.calculateOfflineProgress(
          state: savedState,
          currentTimestampMs: twoYearsLaterMs,
        );

        expect(report, isNotNull);
        // Even though clock jumped 2 years, offline report is capped at offlineCapSeconds (86400s)
        expect(report!.wasCapped, isTrue);
        expect(report.simulatedSeconds, equals(86400.0));
        // Elapsed seconds clamped to 30-day ceiling (2,592,000s)
        expect(report.secondsAway, equals(30 * 86400.0));
      },
    );

    test('Prevent duplicate collection through updated timestamp', () {
      final initial = GameState.initial();
      final t1Ms = 1700000000000;
      final t2Ms = t1Ms + (3600 * 1000); // 1 hour offline

      final savedState = initial.copyWith(lastSavedTimestamp: t1Ms);
      final report = manager.calculateOfflineProgress(
        state: savedState,
        currentTimestampMs: t2Ms,
      );
      expect(report, isNotNull);

      // Once applied, state's lastSavedTimestamp is set to now
      final updatedState = report!.finalState.copyWith(
        lastSavedTimestamp: t2Ms,
      );

      // Immediate second check at same timestamp returns null (preventing infinite reward loop)
      final duplicateReport = manager.calculateOfflineProgress(
        state: updatedState,
        currentTimestampMs: t2Ms,
      );
      expect(duplicateReport, isNull);
    });
  });
}
