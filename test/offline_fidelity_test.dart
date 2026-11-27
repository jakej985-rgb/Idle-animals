import 'package:extinction_sanctuary/core/offline/offline_manager.dart';
import 'package:extinction_sanctuary/core/simulation/simulation_engine.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plays [seconds] the way the app does in the foreground: one engine tick per
/// second, with no offline report involved.
GameState _playLive(GameState start, int seconds) {
  const engine = SimulationEngine();
  var state = start;
  for (var i = 0; i < seconds; i++) {
    state = engine.tick(state: state, dt: 1.0).nextState;
  }
  return state;
}

OfflineReport _goAway(GameState start, int seconds) {
  final report = const OfflineManager().calculateOfflineProgress(
    state: start,
    currentTimestampMs: start.lastSavedTimestamp + seconds * 1000,
  );
  expect(report, isNotNull);
  return report!;
}

/// A sanctuary that has run dry: the slice size is visible here because
/// happiness and feeding resolve differently for a 5s slice than for a minute.
const Habitat _dryIsland = Habitat(
  id: 'dodo_island',
  name: 'Dodo Island Sanctuary',
  speciesId: 'dodo',
  population: 8,
  food: 4.0,
  water: 4.0,
);

void main() {
  group('Offline earnings match live play', () {
    test(
      'two hours away earns what two hours in the app would have earned',
      () {
        const seconds = 7200;
        final start = GameState.initial();
        final live = _playLive(start, seconds);
        final report = _goAway(start, seconds);

        final liveCredits = live.credits - start.credits;
        final liveDna = live.dna - start.dna;

        expect(report.wasCapped, isFalse);
        expect(report.simulatedSeconds, equals(seconds.toDouble()));
        // The old 100-step ceiling simulated this in eighteen-second lumps.
        expect(report.creditsEarned, closeTo(liveCredits, liveCredits * 0.005));
        expect(report.dnaRecovered, closeTo(liveDna, liveDna * 0.005));
        expect(
          report.animalsBorn,
          equals(live.totalAnimalsBred - start.totalAnimalsBred),
        );
        expect(
          report.finalState.habitats['dodo_island']!.population,
          equals(live.habitats['dodo_island']!.population),
        );
      },
    );

    test('a starved sanctuary still tracks live play over half an hour', () {
      const seconds = 1800;
      final start = GameState.initial().copyWith(
        habitats: const {'dodo_island': _dryIsland},
      );
      final live = _playLive(start, seconds);
      final report = _goAway(start, seconds);

      final liveCredits = live.credits - start.credits;

      expect(report.wasCapped, isFalse);
      // Feeding and happiness resolve per slice, so a coarse slice diverges
      // here: eighteen-second steps landed about 3.4% below live play, which
      // this 2% bound would have caught.
      expect(report.creditsEarned, closeTo(liveCredits, liveCredits * 0.02));
      expect(
        report.animalsBorn,
        equals(live.totalAnimalsBred - start.totalAnimalsBred),
      );
      expect(
        report.finalState.habitats['dodo_island']!.population,
        equals(live.habitats['dodo_island']!.population),
      );
    });
  });
}
