import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/core/simulation/simulation_engine.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/habitat.dart';

void main() {
  group('Multi-Habitat & Multi-Species Simulation Tests (Phase 8 & 9)', () {
    const engine = SimulationEngine();

    test('Simulates both Dodo Island and Tasmanian Forest concurrently', () {
      final state = GameState.initial();
      final multiHabitatState = state.copyWith(
        unlockedSpeciesIds: ['dodo', 'thylacine'],
        habitats: {
          'dodo_island': const Habitat(
            id: 'dodo_island',
            name: 'Dodo Island Sanctuary',
            speciesId: 'dodo',
            level: 1,
            population: 10,
          ),
          'tasman_forest': const Habitat(
            id: 'tasman_forest',
            name: 'Tasmanian Forest Reserve',
            speciesId: 'thylacine',
            biomeType: 'australian_forest',
            level: 1,
            population: 5,
          ),
        },
      );

      final res = engine.tick(state: multiHabitatState, dt: 1.0);

      // Verify both habitats produced output and consumed food
      expect(
        res.creditsGenerated,
        greaterThan(20.0),
      ); // 10 dodos * 1.0 + 5 thylacines * 2.5
      expect(res.dnaGenerated, greaterThan(5.0));
      expect(res.nextState.habitats['dodo_island']!.food, lessThan(100.0));
      expect(res.nextState.habitats['tasman_forest']!.food, lessThan(100.0));
    });
  });
}
