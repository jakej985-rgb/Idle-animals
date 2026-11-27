import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:extinction_sanctuary/screens/sanctuary_screen.dart';
import 'package:extinction_sanctuary/screens/upgrades_sheet.dart';
import 'package:extinction_sanctuary/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a fixed state and never starts the game loops, so no timers, saves
/// or offline reports leak into a rendering test.
class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

const _habitat = Habitat(
  id: 'dodo_island',
  name: 'Dodo Island Sanctuary',
  speciesId: 'dodo',
  biomeType: 'tropical_island',
  population: 8,
  level: 2,
  food: 62.0,
  water: 74.0,
  happiness: 88.0,
);

GameState _goldenState() => GameState.initial().copyWith(
      credits: 1250.0,
      dna: 40.0,
      activeHabitatId: 'dodo_island',
      habitats: const {'dodo_island': _habitat},
    );

Widget _harness(GameState state, Widget home) {
  return ProviderScope(
    overrides: [gameProvider.overrideWith(() => _FixedGameNotifier(state))],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    ),
  );
}

/// Renders at a fixed phone viewport so the captured frame is reproducible.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('UI Golden Tests', () {
    testWidgets('sanctuary screen renders unchanged', (tester) async {
      _usePhoneViewport(tester);

      await tester.pumpWidget(
        _harness(_goldenState(), const SanctuaryScreen(viewportSeed: 7)),
      );
      // Two fixed frames land the viewport animation on the same phase.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(SanctuaryScreen),
        matchesGoldenFile('goldens/sanctuary_screen.png'),
      );
    });

    testWidgets('upgrades sheet renders unchanged', (tester) async {
      _usePhoneViewport(tester);

      await tester.pumpWidget(
        _harness(
          _goldenState(),
          Scaffold(
            backgroundColor: AppColors.background,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(height: 620, child: const UpgradesSheet()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(UpgradesSheet),
        matchesGoldenFile('goldens/upgrades_sheet.png'),
      );
    });
  });
}
