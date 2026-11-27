import 'dart:convert';

import 'package:extinction_sanctuary/core/save/save_codec.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveCodec', () {
    test('round-trips credits, habitat ids and progress counters', () {
      final state = GameState.initial().copyWith(
        credits: 987.5,
        dna: 42.0,
        totalAnimalsBred: 7,
      );

      final token = SaveCodec.encode(state);
      expect(token, startsWith(SaveCodec.prefix));

      final decoded = SaveCodec.decode(token);
      expect(decoded, isNotNull);
      expect(decoded!.credits, equals(987.5));
      expect(decoded.dna, equals(42.0));
      expect(decoded.totalAnimalsBred, equals(7));
      expect(decoded.habitats['dodo_island']!.id, equals('dodo_island'));
    });

    test('accepts a token that a paste wrapped onto several lines', () {
      final token = SaveCodec.encode(GameState.initial());
      final body = token.substring(SaveCodec.prefix.length);
      final wrapped =
          ' ${SaveCodec.prefix}${body.substring(0, 10)}\n${body.substring(10)} ';

      expect(SaveCodec.decode(wrapped)?.credits, equals(60.0));
    });

    test('rejects text that is not a save token', () {
      expect(SaveCodec.decode(''), isNull);
      expect(SaveCodec.decode('hello'), isNull);
      expect(SaveCodec.decode('{"credits": 500}'), isNull);
    });

    test('rejects a truncated token instead of loading part of it', () {
      final token = SaveCodec.encode(GameState.initial());
      expect(SaveCodec.decode(token.substring(0, token.length - 8)), isNull);
    });

    test('rejects JSON that is not a complete save', () {
      final payload = base64Url.encode(utf8.encode('{"credits": 5}'));
      expect(SaveCodec.decode('${SaveCodec.prefix}$payload'), isNull);
    });

    test('rejects a save with no habitats', () {
      final payload = base64Url.encode(
        utf8.encode('{"credits": 5, "habitats": {}}'),
      );
      expect(SaveCodec.decode('${SaveCodec.prefix}$payload'), isNull);
    });
  });

  group('Importing a save', () {
    test('applies the imported progress and persists it', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gameProvider);
      await pumpEventQueue();

      final notifier = container.read(gameProvider.notifier);
      final token = SaveCodec.encode(
        GameState.initial().copyWith(credits: 4321.0, dna: 12.0),
      );

      expect(notifier.importSave(token), isTrue);
      expect(container.read(gameProvider).credits, equals(4321.0));

      await pumpEventQueue();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('extinction_sanctuary_save_v2'), contains('4321'));
    });

    test('leaves the current game alone when the text is not a save', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gameProvider);
      await pumpEventQueue();

      final notifier = container.read(gameProvider.notifier);

      expect(notifier.importSave('nonsense'), isFalse);
      expect(container.read(gameProvider).credits, equals(60.0));
    });

    test('a save with no habitats leaves the current game in place', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gameProvider);
      await pumpEventQueue();

      final notifier = container.read(gameProvider.notifier);
      final payload = base64Url.encode(
        utf8.encode('{"credits": 5, "habitats": {}}'),
      );

      expect(notifier.importSave('${SaveCodec.prefix}$payload'), isFalse);
      expect(container.read(gameProvider).credits, equals(60.0));
      expect(container.read(gameProvider).habitats, isNotEmpty);
    });
  });
}
