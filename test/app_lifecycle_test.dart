import 'dart:convert';

import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _saveWithCredits(double credits) {
  final save = GameState.initial().toJson();
  save['credits'] = credits;
  return save;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App lifecycle save handling', () {
    test('A pause during the first load does not overwrite the save', () async {
      final save = _saveWithCredits(4321.0)
        ..['lastSavedTimestamp'] = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(save),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reading the notifier starts the async load; pausing right away used to
      // persist the temporary GameState.initial() over the real save.
      final notifier = container.read(gameProvider.notifier);
      await notifier.handleAppPaused();

      expect(container.read(gameProvider).credits, greaterThan(4000.0));

      final prefs = await SharedPreferences.getInstance();
      final persisted = jsonDecode(
        prefs.getString('extinction_sanctuary_save_v2')!,
      ) as Map<String, dynamic>;
      expect(persisted['credits'], greaterThan(4000.0));
    });

    test('A background gap under the report threshold still earns', () async {
      final save = _saveWithCredits(500.0)
        ..['lastSavedTimestamp'] = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': jsonEncode(save),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gameProvider);
      await pumpEventQueue();

      final notifier = container.read(gameProvider.notifier);
      await notifier.handleAppPaused();
      final creditsBefore = container.read(gameProvider).credits;

      // Stamp the gap right before the resume instead of when the container is
      // built. Only a few synchronous lines run between the two, so even a slow
      // runner stays far below the 15s report threshold and cannot flake this.
      notifier.state = notifier.state.copyWith(
        lastSavedTimestamp: DateTime.now().millisecondsSinceEpoch - 5000,
      );
      await notifier.handleAppResumed();

      // One dodo earns 1 credit/s, so a 5s gap is ~5 credits. The old code
      // advanced the timestamp without simulating and earned nothing.
      expect(
        container.read(gameProvider).credits,
        greaterThan(creditsBefore),
      );
      expect(notifier.pendingOfflineReport, isNull);
    });
  });
}
