import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extinction_sanctuary/core/save/save_service.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveService Migration & Corruption Recovery Tests', () {
    test('Migrates legacy v1 save payload to v2 schema seamlessly', () async {
      // Create legacy save data (schemaVersion missing, totalDodosBred present)
      final initial = GameState.initial();
      final legacyJsonMap = initial.toJson();
      legacyJsonMap.remove('schemaVersion');
      legacyJsonMap['totalDodosBred'] = 42;
      legacyJsonMap.remove('totalAnimalsBred');

      final legacyString = jsonEncode(legacyJsonMap);

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v1': legacyString,
      });

      final saveService = SaveService();
      final loaded = await saveService.loadGame();

      expect(loaded, isNotNull);
      expect(loaded!.schemaVersion, equals(2));
      expect(loaded.totalAnimalsBred, equals(42));
      expect(loaded.totalDodosBred, equals(42)); // backward compatible alias

      // Verify v2 save key is now written
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('extinction_sanctuary_save_v2'), isTrue);
    });

    test(
      'Recovers gracefully from corrupted save JSON without crashing',
      () async {
        SharedPreferences.setMockInitialValues({
          'extinction_sanctuary_save_v2': '{corrupted_malformed_json_###',
        });

        final saveService = SaveService();
        final recovered = await saveService.loadGame();

        // Rather than crashing with FormatException, returns safe initial state
        expect(recovered, isNotNull);
        expect(recovered!.credits, equals(60.0));
        expect(recovered.schemaVersion, equals(2));
      },
    );

    test('Loads a save whose habitat entry has no id instead of resetting', () async {
      // Regression: Habitat.fromJson used to cast id to a non-null String, so a
      // renamed/missing field threw and loadGame fell back to GameState.initial().
      final jsonMap = GameState.initial().toJson();
      jsonMap['credits'] = 1234.5;
      final habitats = jsonMap['habitats'] as Map<String, dynamic>;
      final island = habitats['dodo_island'] as Map<String, dynamic>;
      island.remove('id');

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
      });

      final loaded = await SaveService().loadGame();

      expect(loaded, isNotNull);
      // A reset would start over at 60 credits with the default sanctuary.
      expect(loaded!.credits, equals(1234.5));
      expect(loaded.habitats.containsKey('dodo_island'), isTrue);
      expect(
        loaded.habitats['dodo_island']!.name,
        equals('Dodo Island Sanctuary'),
      );
      // The map key is the habitat's identity, so a missing field must not
      // leave the id empty (care actions look the habitat up by `id`).
      expect(loaded.habitats['dodo_island']!.id, equals('dodo_island'));
    });

    test('A recovered habitat id still resolves care actions', () async {
      final jsonMap = GameState.initial().toJson();
      jsonMap['credits'] = 500.0;
      jsonMap['lastSavedTimestamp'] = DateTime.now().millisecondsSinceEpoch;
      final habitats = jsonMap['habitats'] as Map<String, dynamic>;
      final island = habitats['dodo_island'] as Map<String, dynamic>;
      island.remove('id');
      island['food'] = 10.0;

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gameProvider); // starts the async load
      await pumpEventQueue();

      final notifier = container.read(gameProvider.notifier);
      final habitat = container.read(gameProvider).habitats['dodo_island']!;

      expect(habitat.id, equals('dodo_island'));
      expect(notifier.feedHabitat(habitat.id), isTrue);
      expect(
        container.read(gameProvider).habitats['dodo_island']!.food,
        equals(100.0),
      );
    });
  });
}
