import 'dart:math';
import '../../models/game_state.dart';
import '../simulation/simulation_engine.dart';

class OfflineReport {
  final double secondsAway;
  final double simulatedSeconds;
  final bool wasCapped;
  final int animalsBorn;
  int get dodosBorn => animalsBorn;
  final double creditsEarned;
  final double dnaRecovered;
  final double researchGathered;
  final GameState finalState;

  const OfflineReport({
    required this.secondsAway,
    required this.simulatedSeconds,
    required this.wasCapped,
    required this.animalsBorn,
    required this.creditsEarned,
    required this.dnaRecovered,
    required this.researchGathered,
    required this.finalState,
  });

  String get awayDurationFormatted {
    final int minutes = (secondsAway / 60).floor();
    final int hours = (minutes / 60).floor();
    final int remMin = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remMin}m';
    } else {
      return '${remMin}m';
    }
  }
}

class OfflineManager {
  final SimulationEngine engine;

  const OfflineManager({this.engine = const SimulationEngine()});

  OfflineReport? calculateOfflineProgress({
    required GameState state,
    required int currentTimestampMs,
  }) {
    // 1. Invariant checks
    if (state.lastSavedTimestamp <= 0 || currentTimestampMs <= 0) {
      return null;
    }

    final elapsedMs = currentTimestampMs - state.lastSavedTimestamp;

    // 2. Protect against negative elapsed time (clock turned backwards)
    if (elapsedMs <= 0) {
      return null;
    }

    // 3. Minimum threshold: under 15 seconds produces no modal
    if (elapsedMs < 15000) {
      return null;
    }

    final double rawElapsedSec = elapsedMs / 1000.0;

    // 4. Protect against extreme future timestamps / overflow (cap at 30 days max)
    const double maxExtremeSec = 3600.0 * 24.0 * 30.0;
    final double elapsedSec = min(rawElapsedSec, maxExtremeSec);

    final double capSec = state.offlineCapSeconds;
    final double simSec = min(elapsedSec, capSec);
    final bool wasCapped = elapsedSec > capSec;

    // 5. Simulate in discrete slices (maximum 100 steps for speed and precision)
    final int steps = min(100, max(1, (simSec / 5.0).ceil()));
    final double dtPerStep = simSec / steps;

    var currentState = state;
    double totalCredits = 0;
    double totalDna = 0;
    double totalResearch = 0;
    int totalAnimalsBorn = 0;

    for (int i = 0; i < steps; i++) {
      final res = engine.tick(state: currentState, dt: dtPerStep);
      currentState = res.nextState;
      totalCredits += res.creditsGenerated;
      totalDna += res.dnaGenerated;
      totalResearch += res.researchGenerated;
      totalAnimalsBorn += res.animalsBorn;
    }

    // 6. Update lastSavedTimestamp to current time to prevent duplicate collection
    final committedState = currentState.copyWith(
      lastSavedTimestamp: currentTimestampMs,
    );

    return OfflineReport(
      secondsAway: elapsedSec,
      simulatedSeconds: simSec,
      wasCapped: wasCapped,
      animalsBorn: totalAnimalsBorn,
      creditsEarned: totalCredits,
      dnaRecovered: totalDna,
      researchGathered: totalResearch,
      finalState: committedState,
    );
  }
}
