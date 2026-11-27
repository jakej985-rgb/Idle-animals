import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/models/expedition.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';

void main() {
  group('Expedition & Fossil Exploration Tests (Phase 7)', () {
    test('Expedition timer counts down and flags completion correctly', () {
      final defaultExps = Expedition.defaultExpeditions();
      final exp = defaultExps.first; // 30s duration
      final startTime = DateTime.now().millisecondsSinceEpoch;

      final runningExp = exp.copyWith(
        isActive: true,
        startedTimestampMs: startTime,
      );

      // At 10s elapsed
      expect(runningExp.checkCompleted(startTime + 10000), isFalse);
      expect(runningExp.getRemainingSeconds(startTime + 10000), closeTo(20.0, 0.5));

      // At 35s elapsed
      expect(runningExp.checkCompleted(startTime + 35000), isTrue);
      expect(runningExp.getRemainingSeconds(startTime + 35000), equals(0.0));
    });

    test('Claiming expedition grants fossil loot and unlocks Thylacine regional habitat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      // Grant credits for expedition
      notifier.state = notifier.state.copyWith(credits: 500.0);

      final started = notifier.startExpedition('tasman_outback');
      expect(started, isTrue);

      final exp = notifier.state.expeditions['tasman_outback']!;
      expect(exp.isActive, isTrue);

      // Fast-forward expedition to completed
      notifier.state = notifier.state.copyWith(
        expeditions: {
          ...notifier.state.expeditions,
          'tasman_outback': exp.copyWith(isCompleted: true),
        },
      );

      final claimed = notifier.claimExpedition('tasman_outback');
      expect(claimed, isTrue);

      // Verify Thylacine unlocked and habitat created
      expect(notifier.state.unlockedSpeciesIds, contains('thylacine'));
      expect(notifier.state.habitats.containsKey('tasman_forest'), isTrue);
      expect(notifier.state.habitats['tasman_forest']!.speciesId, equals('thylacine'));
      expect(notifier.state.totalExpeditionsCompleted, equals(1));
      expect(notifier.state.fossilInventory.isNotEmpty, isTrue);
    });
  });
}
