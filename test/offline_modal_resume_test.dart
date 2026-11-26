import 'package:extinction_sanctuary/core/offline/offline_manager.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:extinction_sanctuary/screens/sanctuary_screen.dart';
import 'package:extinction_sanctuary/theme/app_theme.dart';
import 'package:extinction_sanctuary/widgets/offline_modal.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fixed-state notifier that can queue offline reports the way a resume does.
class _ResumeNotifier extends GameNotifier {
  _ResumeNotifier(this._initial);

  final GameState _initial;

  @override
  GameState build() => _initial;

  /// The real implementation also flushes a save; tests have no storage.
  @override
  void dismissOfflineReport() {
    pendingOfflineReport = null;
  }

  /// Mirrors `handleAppResumed`: queue the report and publish the advanced
  /// state, which is what makes the screen rebuild.
  void deliver(OfflineReport report) {
    pendingOfflineReport = report;
    state = report.finalState;
  }
}

const _habitat = Habitat(
  id: 'dodo_island',
  name: 'Dodo Island Sanctuary',
  speciesId: 'dodo',
  population: 8,
  level: 2,
);

OfflineReport _report(GameState state, double credits) {
  return OfflineReport(
    secondsAway: 600,
    simulatedSeconds: 600,
    wasCapped: false,
    animalsBorn: 0,
    creditsEarned: credits,
    dnaRecovered: 0,
    researchGathered: 0,
    finalState: state.copyWith(credits: state.credits + credits),
  );
}

/// Advances a frame (running the post-frame dialog call) plus the route
/// transition. Deliberately not `pumpAndSettle`, since the viewport owns
/// long-running animation.
Future<void> _showFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
      'offline modal opens again for a second report after the first is collected',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final notifier = _ResumeNotifier(
      GameState.initial().copyWith(
        activeHabitatId: 'dodo_island',
        habitats: const {'dodo_island': _habitat},
      ),
    );
    final container = ProviderContainer(
      overrides: [gameProvider.overrideWith(() => notifier)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const SanctuaryScreen(viewportSeed: 7),
        ),
      ),
    );
    await _showFrames(tester);
    expect(find.byType(OfflineModal), findsNothing);

    // First backgrounded session.
    notifier.deliver(_report(notifier.state, 12.0));
    await _showFrames(tester);
    expect(find.byType(OfflineModal), findsOneWidget);

    await tester.tap(find.text('COLLECT REWARDS'));
    await _showFrames(tester);
    expect(find.byType(OfflineModal), findsNothing);
    expect(notifier.pendingOfflineReport, isNull);

    // Second backgrounded session: a new report must open a new modal.
    notifier.deliver(_report(notifier.state, 20.0));
    await _showFrames(tester);
    expect(find.byType(OfflineModal), findsOneWidget);
    // Proves it is the second report, not a resurrected first one.
    expect(find.text('+20'), findsOneWidget);
  });
}
