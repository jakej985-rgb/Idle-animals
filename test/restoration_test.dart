import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';

void main() {
  group('Ecosystem Restoration & Prestige Tests (Phase 10)', () {
    test('Ecosystem restoration awards points and resets habitat level', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      final highPopHabitat = const Habitat(
        id: 'dodo_island',
        name: 'Dodo Island Sanctuary',
        speciesId: 'dodo',
        level: 3,
        population: 20,
      );

      notifier.state = notifier.state.copyWith(
        habitats: {'dodo_island': highPopHabitat},
      );

      final expectedPoints = highPopHabitat.calculateRestorationPoints();
      expect(expectedPoints, greaterThanOrEqualTo(10));

      final restored = notifier.restoreEcosystem('dodo_island');
      expect(restored, isTrue);

      // Verify points granted and habitat reset
      expect(notifier.state.restorationPoints, equals(expectedPoints.toDouble()));
      expect(notifier.state.habitats['dodo_island']!.level, equals(1));
      expect(notifier.state.habitats['dodo_island']!.population, equals(1));
      expect(notifier.state.habitats['dodo_island']!.timesRestored, equals(1));
    });

    test('Permanent restoration perks enhance global multipliers', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        restorationPoints: 30.0,
      );

      // Purchase growth boost perk (costs 5 points for Lv 1)
      final bought = notifier.buyRestorationPerk('growth_boost');
      expect(bought, isTrue);
      expect(notifier.state.restorationPerks['growth_boost'], equals(1));
      expect(notifier.state.globalGrowthMultiplier, greaterThan(1.10));
      expect(notifier.state.restorationPoints, equals(25.0));
    });
  });
}
