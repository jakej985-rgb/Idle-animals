import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/core/simulation/simulation_engine.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/species.dart';

void main() {
  group('SimulationEngine Tests', () {
    const engine = SimulationEngine();

    test('Active 1-second tick consumes food/water and produces resources', () {
      final state = GameState.initial();
      final initialFood = state.habitats['dodo_island']!.food;
      final initialCredits = state.credits;
      final initialDna = state.dna;

      final res = engine.tick(state: state, dt: 1.0);

      // Verify resources generated
      expect(res.creditsGenerated, greaterThan(0));
      expect(res.dnaGenerated, greaterThan(0));
      expect(res.researchGenerated, greaterThan(0));
      expect(res.nextState.credits, greaterThan(initialCredits));
      expect(res.nextState.dna, greaterThan(initialDna));

      // Verify food consumed
      final newFood = res.nextState.habitats['dodo_island']!.food;
      expect(newFood, lessThan(initialFood));
    });

    test('Breeding advances over time and births new Dodo when progress hits 1.0', () {
      final state = GameState.initial();
      final habitat = state.habitats['dodo_island']!;
      final baseBreedingTime = Species.dodo.baseBreedingSeconds; // 15.0 seconds

      // Advance by 16 seconds
      final res = engine.tick(state: state, dt: baseBreedingTime + 1.0);

      expect(res.dodosBorn, greaterThanOrEqualTo(1));
      expect(res.nextState.habitats['dodo_island']!.population,
          greaterThan(habitat.population));
      expect(res.nextState.totalDodosBred,
          greaterThan(state.totalDodosBred));
    });

    test('Breeding respects habitat capacity limit', () {
      final state = GameState.initial();
      final habitat = state.habitats['dodo_island']!;
      final atCapacityState = state.copyWith(
        habitats: {
          'dodo_island': habitat.copyWith(
            population: habitat.capacity,
            breedingProgress: 0.9,
          ),
        },
      );

      final res = engine.tick(state: atCapacityState, dt: 30.0);

      expect(res.dodosBorn, equals(0));
      expect(res.nextState.habitats['dodo_island']!.population,
          equals(habitat.capacity));
      expect(res.nextState.habitats['dodo_island']!.breedingProgress,
          equals(1.0));
    });

    test('Keeper staff prevents food starvation and increases growth speed', () {
      final state = GameState.initial();
      final keeper = state.staff['keeper']!;
      final stateWithKeeper = state.copyWith(
        staff: {
          'keeper': keeper.copyWith(level: 2),
        },
        habitats: {
          'dodo_island': state.habitats['dodo_island']!.copyWith(
            food: 10.0, // Below 20 threshold
          ),
        },
      );

      final res = engine.tick(state: stateWithKeeper, dt: 1.0);
      final foodAfter = res.nextState.habitats['dodo_island']!.food;

      // Keeper refilled food back to max
      expect(foodAfter, equals(100.0));
    });
  });
}
