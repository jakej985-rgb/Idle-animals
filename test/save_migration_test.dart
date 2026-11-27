import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extinction_sanctuary/core/save/save_service.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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

    test('The saved habitat map key overrides a stale habitat id', () async {
      final jsonMap = GameState.initial().toJson();
      // A non-default credit balance is what makes a rejected save (which falls
      // back to GameState.initial()) fail this test: the default state already
      // has dodo_island as its habitat id.
      jsonMap['credits'] = 1234.5;
      final habitats = jsonMap['habitats'] as Map<String, dynamic>;
      (habitats['dodo_island'] as Map<String, dynamic>)['id'] =
          'retired_sanctuary_id';

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
      });

      final loaded = await SaveService().loadGame();

      expect(loaded, isNotNull);
      expect(loaded!.credits, equals(1234.5));
      expect(loaded.habitats['dodo_island']!.id, equals('dodo_island'));
    });

    test(
      'Falls back to the previous save when the current one is unreadable',
      () async {
        final previous = GameState.initial().toJson()..['credits'] = 2468.0;
        SharedPreferences.setMockInitialValues({
          'extinction_sanctuary_save_v2': '{corrupted_malformed_json_###',
          'extinction_sanctuary_save_v2_backup': jsonEncode(previous),
        });

        final recovered = await SaveService().loadGame();

        expect(recovered, isNotNull);
        expect(recovered!.credits, equals(2468.0));

        // The recovered payload is promoted back to the live slot so the next
        // launch loads normally instead of repeating the recovery.
        final prefs = await SharedPreferences.getInstance();
        final live = jsonDecode(
          prefs.getString('extinction_sanctuary_save_v2')!,
        ) as Map<String, dynamic>;
        expect(live['credits'], equals(2468.0));
      },
    );

    test('Resets when both the save and its backup are unreadable', () async {
      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': '{corrupted_malformed_json_###',
        'extinction_sanctuary_save_v2_backup': 'also_unreadable_###',
      });

      final recovered = await SaveService().loadGame();

      expect(recovered, isNotNull);
      expect(recovered!.credits, equals(60.0));
    });

    test('A reset does not resurrect the backup on the next load', () async {
      final saved = GameState.initial().toJson()..['credits'] = 900.0;
      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(saved),
        'extinction_sanctuary_save_v2_backup': jsonEncode(saved),
      });

      await SaveService().clearSave();
      final loaded = await SaveService().loadGame();

      // No save at all means a new game, not the progress the player just reset.
      expect(loaded, isNull);
    });

    test(
      'A save from a newer schema loads with its own version intact',
      () async {
        final jsonMap = GameState.initial().toJson()
          ..['schemaVersion'] = 99
          ..['credits'] = 777.0;

        SharedPreferences.setMockInitialValues({
          'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
        });

        final loaded = await SaveService().loadGame();

        expect(loaded, isNotNull);
        expect(loaded!.credits, equals(777.0));
        expect(loaded.schemaVersion, equals(99));
      },
    );

    test(
      'A negative schema version does not walk the migration loop',
      () async {
        final jsonMap = GameState.initial().toJson()
          ..['schemaVersion'] = -2147483648
          ..['credits'] = 333.0;

        SharedPreferences.setMockInitialValues({
          'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
        });

        final clock = Stopwatch()..start();
        final loaded = await SaveService().loadGame();
        clock.stop();

        expect(loaded, isNotNull);
        expect(loaded!.credits, equals(333.0));
        expect(loaded.schemaVersion, equals(GameState.currentSchemaVersion));
        // Unclamped, the loop runs one iteration per integer up to the current
        // schema: about twenty seconds of blocked main thread here, minutes on
        // a phone. Reading a stored version must not cost anything.
        expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
      },
    );

    test('A save with no habitats is recovered, not loaded', () async {
      final noHabitats = GameState.initial().toJson()
        ..['credits'] = 900.0
        ..['habitats'] = <String, dynamic>{};
      final previous = GameState.initial().toJson()..['credits'] = 2468.0;

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(noHabitats),
        'extinction_sanctuary_save_v2_backup': jsonEncode(previous),
      });

      final recovered = await SaveService().loadGame();

      // Loading an empty habitat map throws on the sanctuary screen, i.e. on
      // every launch, so the previous save is used instead.
      expect(recovered, isNotNull);
      expect(recovered!.credits, equals(2468.0));
      expect(recovered.habitats, isNotEmpty);
    });

    test(
      'A backup is returned even when it cannot be promoted to the live slot',
      () async {
        final previous = GameState.initial().toJson()..['credits'] = 777.0;
        SharedPreferences.resetStatic();
        SharedPreferencesStorePlatform.instance = _ReadOnlyPreferencesStore({
          'flutter.extinction_sanctuary_save_v2':
              '{corrupted_malformed_json_###',
          'flutter.extinction_sanctuary_save_v2_backup': jsonEncode(previous),
        });

        final recovered = await SaveService().loadGame();

        // The promotion write fails here; the recovered progress must still be
        // handed back instead of resetting the player to a new game.
        expect(recovered, isNotNull);
        expect(recovered!.credits, equals(777.0));
      },
    );

    test(
      'A save whose active habitat is gone falls back to one it has',
      () async {
        final jsonMap = GameState.initial().toJson()
          ..['credits'] = 500.0
          ..['activeHabitatId'] = 'retired_sanctuary_id'
          ..['lastSavedTimestamp'] = DateTime.now().millisecondsSinceEpoch;

        SharedPreferences.setMockInitialValues({
          'extinction_sanctuary_save_v2': jsonEncode(jsonMap),
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(gameProvider);
        await pumpEventQueue();

        final state = container.read(gameProvider);
        final notifier = container.read(gameProvider.notifier);
        final level = state.habitats['dodo_island']!.level;

        expect(state.activeHabitatId, equals('dodo_island'));
        expect(state.habitats.containsKey(state.activeHabitatId), isTrue);

        // Care actions and upgrade effects address the active habitat by id; a
        // stale id made them return false or spend credits for no effect.
        expect(notifier.feedHabitat(state.activeHabitatId), isTrue);
        expect(notifier.buyUpgrade('habitat_expansion'), isTrue);
        expect(
          container.read(gameProvider).habitats[state.activeHabitatId]!.level,
          equals(level + 1),
        );
      },
    );
  });
}

/// Reads normally but rejects every write, like a device whose storage has
/// gone read-only after the save was written.
class _ReadOnlyPreferencesStore extends InMemorySharedPreferencesStore {
  _ReadOnlyPreferencesStore(super.data) : super.withData();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    throw StateError('the preferences store is read-only');
  }
}
