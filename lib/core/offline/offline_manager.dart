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
    final elapsedMs = currentTimestampMs - state.lastSavedTimestamp;
    if (elapsedMs < 15000) {
      // Less than 15 seconds away, no offline modal needed
      return null;
    }

    final double elapsedSec = elapsedMs / 1000.0;
    final double capSec = state.offlineCapSeconds;
    final double simSec = min(elapsedSec, capSec);
    final bool wasCapped = elapsedSec > capSec;

    // Simulate in discrete slices (maximum 100 steps for speed and precision)
    final int steps = min(100, max(1, (simSec / 5.0).ceil()));
    final double dtPerStep = simSec / steps;

    var currentState = state;
    double totalCredits = 0;
    double totalDna = 0;
    double totalResearch = 0;
    int totalDodosBorn = 0;

    for (int i = 0; i < steps; i++) {
      final res = engine.tick(state: currentState, dt: dtPerStep);
      currentState = res.nextState;
      totalCredits += res.creditsGenerated;
      totalDna += res.dnaGenerated;
      totalResearch += res.researchGenerated;
      totalDodosBorn += res.animalsBorn;
    }

    return OfflineReport(
      secondsAway: elapsedSec,
      simulatedSeconds: simSec,
      wasCapped: wasCapped,
      animalsBorn: totalDodosBorn,
      creditsEarned: totalCredits,
      dnaRecovered: totalDna,
      researchGathered: totalResearch,
      finalState: currentState,
    );
  }
}
