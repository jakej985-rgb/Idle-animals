import 'dart:async';

import 'package:extinction_sanctuary/main.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:extinction_sanctuary/screens/sanctuary_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A notifier whose load never finishes until the test says so, so the frame
/// between `build()` and the first applied save can be inspected.
class _GatedNotifier extends GameNotifier {
  final Completer<void> gate = Completer<void>();

  @override
  GameState build() => GameState.initial();

  @override
  Future<void> get ready => gate.future;
}

void main() {
  testWidgets(
    'shows a splash instead of the default game until the save loads',
    (tester) async {
      final notifier = _GatedNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith(() => notifier)],
          child: const ExtinctionSanctuaryApp(),
        ),
      );

      // The default 60-credit state must not be presented as the player's game:
      // anything they tapped here would be discarded by the load.
      expect(find.byType(SanctuaryScreen), findsNothing);

      notifier.gate.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(SanctuaryScreen), findsOneWidget);
    },
  );
}
