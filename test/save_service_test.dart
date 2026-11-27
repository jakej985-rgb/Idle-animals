import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/models/game_state.dart';

void main() {
  group('SaveService & Model Serialization Tests', () {
    test('GameState converts to JSON and restores accurately', () {
      final state = GameState.initial();
      final jsonMap = state.toJson();

      final restored = GameState.fromJson(jsonMap);

      expect(restored.credits, equals(state.credits));
      expect(restored.dna, equals(state.dna));
      expect(restored.research, equals(state.research));
      expect(restored.habitats.length, equals(state.habitats.length));
      expect(
        restored.habitats['dodo_island']!.name,
        equals('Dodo Island Sanctuary'),
      );
      expect(restored.staff['keeper']!.name, equals('Sarah the Keeper'));
      expect(
        restored.upgrades['auto_feeder']!.title,
        equals('Solar Automated Feeder'),
      );
      expect(
        restored.researchNodes['incubation']!.title,
        equals('Accelerated Incubation'),
      );
      expect(restored.unlockedSpeciesIds, contains('dodo'));
    });
  });
}
