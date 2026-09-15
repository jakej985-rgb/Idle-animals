import 'dart:math';
import '../../models/game_state.dart';
import '../../models/habitat.dart';
import '../../models/species.dart';

class SimulationResult {
  final GameState nextState;
  final double creditsGenerated;
  final double dnaGenerated;
  final double researchGenerated;
  final int dodosBorn;

  const SimulationResult({
    required this.nextState,
    required this.creditsGenerated,
    required this.dnaGenerated,
    required this.researchGenerated,
    required this.dodosBorn,
  });
}

class SimulationEngine {
  const SimulationEngine();

  SimulationResult tick({
    required GameState state,
    required double dt, // seconds elapsed
  }) {
    if (dt <= 0) {
      return SimulationResult(
        nextState: state,
        creditsGenerated: 0,
        dnaGenerated: 0,
        researchGenerated: 0,
        dodosBorn: 0,
      );
    }

    double totalCreditsGen = 0;
    double totalDnaGen = 0;
    double totalResearchGen = 0;
    int totalNewDodos = 0;

    final updatedHabitats = Map<String, Habitat>.from(state.habitats);

    // Retrieve staff & upgrade bonuses
    final keeper = state.staff['keeper'];
    final int keeperLevel = keeper?.level ?? 0;
    final bool hasKeeper = keeperLevel > 0;

    final autoFeederUpgrade = state.upgrades['auto_feeder'];
    final bool hasAutoFeeder =
        (autoFeederUpgrade != null && autoFeederUpgrade.currentLevel > 0);

    final autoWaterUpgrade = state.upgrades['auto_water'];
    final bool hasAutoWater =
        (autoWaterUpgrade != null && autoWaterUpgrade.currentLevel > 0);

    final nestingUpgrade = state.upgrades['breeding_ground'];
    final int nestingLevel = nestingUpgrade?.currentLevel ?? 0;

    final dnaUpgrade = state.upgrades['dna_sequencer'];
    final int dnaUpgradeLevel = dnaUpgrade?.currentLevel ?? 0;

    final incubationResearch =
        state.researchNodes['incubation']?.isUnlocked ?? false;
    final nutritionResearch =
        state.researchNodes['nutrition']?.isUnlocked ?? false;
    final ancientDnaResearch =
        state.researchNodes['ancient_dna']?.isUnlocked ?? false;

    for (final entry in state.habitats.entries) {
      final habitatId = entry.key;
      var habitat = entry.value;

      // Currently focusing on Dodo MVP
      final species = Species.dodo;
      final pop = habitat.population;

      // 1. Food & Water consumption
      final foodRateMultiplier = nutritionResearch ? 0.5 : 1.0;
      final foodConsumed =
          species.baseFoodConsumptionPerSec * pop * foodRateMultiplier * dt;
      final waterConsumed = species.baseWaterConsumptionPerSec * pop * dt;

      var currentFood = max(0.0, habitat.food - foodConsumed);
      var currentWater = max(0.0, habitat.water - waterConsumed);

      // Automated systems or Keeper refill
      if (hasAutoFeeder || (hasKeeper && currentFood < 20.0)) {
        currentFood = habitat.maxFood;
      }
      if (hasAutoWater || (hasKeeper && currentWater < 20.0)) {
        currentWater = habitat.maxWater;
      }

      // 2. Happiness calculation
      var currentHappiness = habitat.happiness;
      final hasResources = currentFood > 0 && currentWater > 0;

      if (hasResources) {
        // Drifts up towards 100%
        currentHappiness = min(100.0, currentHappiness + (4.0 * dt));
      } else {
        // Drifts down to minimum 25% (conservation friendly, no death)
        final minHappiness = 25.0 + (keeperLevel * 5.0);
        currentHappiness = max(minHappiness, currentHappiness - (2.5 * dt));
      }

      // 3. Breeding Progression
      final happinessMult = (currentHappiness / 100.0).clamp(0.2, 1.4);
      final keeperBreedingMult = 1.0 + (keeperLevel * 0.15);
      final nestingBreedingMult = 1.0 + (nestingLevel * 0.15);
      final incubationMult = incubationResearch ? 1.25 : 1.0;

      final breedingSpeedRate = (1.0 / species.baseBreedingSeconds) *
          happinessMult *
          keeperBreedingMult *
          nestingBreedingMult *
          incubationMult;

      var breedingProgress = habitat.breedingProgress + (breedingSpeedRate * dt);
      var currentPop = habitat.population;
      var habitatNewBorns = 0;

      while (breedingProgress >= 1.0 && currentPop < habitat.capacity) {
        currentPop += 1;
        breedingProgress -= 1.0;
        habitatNewBorns += 1;
      }

      if (currentPop >= habitat.capacity && breedingProgress > 1.0) {
        breedingProgress = 1.0; // Maxed until expansion
      }

      totalNewDodos += habitatNewBorns;

      // 4. Resource Generation
      final dnaMultiplier =
          (1.0 + (dnaUpgradeLevel * 0.20)) * (ancientDnaResearch ? 1.5 : 1.0);

      final credsProduced =
          currentPop * species.baseCreditsRatePerSec * happinessMult * dt;
      final dnaProduced = currentPop *
          species.baseDnaRatePerSec *
          happinessMult *
          dnaMultiplier *
          dt;
      final resProduced =
          currentPop * species.baseResearchRatePerSec * happinessMult * dt;

      totalCreditsGen += credsProduced;
      totalDnaGen += dnaProduced;
      totalResearchGen += resProduced;

      updatedHabitats[habitatId] = habitat.copyWith(
        food: currentFood,
        water: currentWater,
        happiness: currentHappiness,
        population: currentPop,
        breedingProgress: breedingProgress,
        hasAutoFeeder: hasAutoFeeder,
        hasAutoWater: hasAutoWater,
      );
    }

    final nextState = state.copyWith(
      credits: state.credits + totalCreditsGen,
      dna: state.dna + totalDnaGen,
      research: state.research + totalResearchGen,
      habitats: updatedHabitats,
      totalDodosBred: state.totalDodosBred + totalNewDodos,
      lastSavedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    return SimulationResult(
      nextState: nextState,
      creditsGenerated: totalCreditsGen,
      dnaGenerated: totalDnaGen,
      researchGenerated: totalResearchGen,
      dodosBorn: totalNewDodos,
    );
  }
}
