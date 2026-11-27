import 'dart:math';

import '../../models/expedition.dart';
import '../../models/game_state.dart';
import '../../models/habitat.dart';
import '../../models/mission.dart';
import '../../models/species.dart';

class SimulationResult {
  final GameState nextState;
  final double creditsGenerated;
  final double dnaGenerated;
  final double researchGenerated;
  final int animalsBorn;
  int get dodosBorn => animalsBorn;

  const SimulationResult({
    required this.nextState,
    required this.creditsGenerated,
    required this.dnaGenerated,
    required this.researchGenerated,
    required this.animalsBorn,
  });
}

/// Instantaneous resource output, in units per second.
class ProductionRates {
  final double creditsPerSec;
  final double dnaPerSec;
  final double researchPerSec;

  const ProductionRates({
    required this.creditsPerSec,
    required this.dnaPerSec,
    required this.researchPerSec,
  });
}

class SimulationEngine {
  const SimulationEngine();

  /// Per-second output for one habitat at a given population and happiness.
  /// The currency header reaches it through [totalRates], so what the player
  /// sees is produced by the same formula as what they earn.
  static ProductionRates _ratesFor({
    required GameState state,
    required String speciesId,
    required int population,
    required double happiness,
  }) {
    final species = Species.fromId(speciesId);
    final happinessMult = Habitat.happinessMultiplierFor(happiness);

    return ProductionRates(
      creditsPerSec: population * species.baseCreditsRatePerSec * happinessMult,
      dnaPerSec:
          population *
          species.baseDnaRatePerSec *
          happinessMult *
          _dnaMultiplier(state),
      researchPerSec:
          population *
          species.baseResearchRatePerSec *
          happinessMult *
          state.globalResearchMultiplier,
    );
  }

  /// Total output across every habitat at its currently stored values.
  static ProductionRates totalRates(GameState state) {
    var credits = 0.0;
    var dna = 0.0;
    var research = 0.0;
    for (final habitat in state.habitats.values) {
      final rates = _ratesFor(
        state: state,
        speciesId: habitat.speciesId,
        population: habitat.population,
        happiness: habitat.happiness,
      );
      credits += rates.creditsPerSec;
      dna += rates.dnaPerSec;
      research += rates.researchPerSec;
    }
    return ProductionRates(
      creditsPerSec: credits,
      dnaPerSec: dna,
      researchPerSec: research,
    );
  }

  static double _dnaMultiplier(GameState state) {
    final dnaUpgradeLevel = state.upgrades['dna_sequencer']?.currentLevel ?? 0;
    final ancientDnaResearch =
        state.researchNodes['ancient_dna']?.isUnlocked ?? false;
    return (1.0 + (dnaUpgradeLevel * 0.20)) *
        (ancientDnaResearch ? 1.5 : 1.0) *
        state.globalDnaMultiplier;
  }

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
        animalsBorn: 0,
      );
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    double totalCreditsGen = 0;
    double totalDnaGen = 0;
    double totalResearchGen = 0;
    int totalNewAnimals = 0;

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

    final incubationResearch =
        state.researchNodes['incubation']?.isUnlocked ?? false;
    final nutritionResearch =
        state.researchNodes['nutrition']?.isUnlocked ?? false;

    // 1. Simulate each habitat concurrently
    for (final entry in state.habitats.entries) {
      final habitatId = entry.key;
      var habitat = entry.value;

      final species = Species.fromId(habitat.speciesId);
      final pop = habitat.population;

      // Need consumption
      final foodRateMultiplier = nutritionResearch ? 0.5 : 1.0;
      final foodConsumed =
          species.baseFoodConsumptionPerSec * pop * foodRateMultiplier * dt;
      final waterConsumed = species.baseWaterConsumptionPerSec * pop * dt;

      var currentFood = max(0.0, habitat.food - foodConsumed);
      var currentWater = max(0.0, habitat.water - waterConsumed);

      // Automated systems or Keeper refill
      if (habitat.hasAutoFeeder ||
          hasAutoFeeder ||
          (hasKeeper && currentFood < 20.0)) {
        currentFood = habitat.maxFood;
      }
      if (habitat.hasAutoWater ||
          hasAutoWater ||
          (hasKeeper && currentWater < 20.0)) {
        currentWater = habitat.maxWater;
      }

      // Happiness calculation
      var currentHappiness = habitat.happiness;
      final hasResources = currentFood > 0 && currentWater > 0;

      if (hasResources) {
        currentHappiness = min(100.0, currentHappiness + (4.0 * dt));
      } else {
        final minHappiness = 25.0 + (keeperLevel * 5.0);
        currentHappiness = max(minHappiness, currentHappiness - (2.5 * dt));
      }

      // Breeding Progression
      final happinessMult = Habitat.happinessMultiplierFor(currentHappiness);
      final keeperBreedingMult = 1.0 + (keeperLevel * 0.15);
      final nestingBreedingMult = 1.0 + (nestingLevel * 0.15);
      final incubationMult = incubationResearch ? 1.25 : 1.0;
      final globalGrowthMult = state.globalGrowthMultiplier;

      final breedingSpeedRate =
          (1.0 / species.baseBreedingSeconds) *
          happinessMult *
          keeperBreedingMult *
          nestingBreedingMult *
          incubationMult *
          globalGrowthMult;

      var breedingProgress =
          habitat.breedingProgress + (breedingSpeedRate * dt);
      var currentPop = habitat.population;
      var habitatNewBorns = 0;

      while (breedingProgress >= 1.0 && currentPop < habitat.capacity) {
        currentPop += 1;
        breedingProgress -= 1.0;
        habitatNewBorns += 1;
      }

      if (currentPop >= habitat.capacity && breedingProgress > 1.0) {
        breedingProgress = 1.0;
      }

      totalNewAnimals += habitatNewBorns;

      // Resource Generation
      final rates = _ratesFor(
        state: state,
        speciesId: habitat.speciesId,
        population: currentPop,
        happiness: currentHappiness,
      );

      totalCreditsGen += rates.creditsPerSec * dt;
      totalDnaGen += rates.dnaPerSec * dt;
      totalResearchGen += rates.researchPerSec * dt;

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

    // 2. Advance active expeditions
    final updatedExpeditions = Map<String, Expedition>.from(state.expeditions);
    for (final expEntry in state.expeditions.entries) {
      final exp = expEntry.value;
      if (exp.isActive && !exp.isCompleted) {
        if (exp.checkCompleted(nowMs)) {
          updatedExpeditions[expEntry.key] = exp.copyWith(isCompleted: true);
        }
      }
    }

    // 3. Update Mission Progress
    final updatedMissions = Map<String, Mission>.from(state.missions);
    int totalPop = updatedHabitats.values.fold(
      0,
      (sum, h) => sum + h.population,
    );

    for (final mEntry in state.missions.entries) {
      final m = mEntry.value;
      if (!m.isCompleted) {
        int current = m.currentProgress;
        if (m.id == 'pop_5' || m.id == 'pop_30') {
          current = totalPop;
        } else if (m.id == 'first_expedition') {
          current = state.totalExpeditionsCompleted;
        } else if (m.id == 'keeper_upgrade') {
          current = keeperLevel;
        } else if (m.id == 'unlock_thylacine') {
          current = state.unlockedSpeciesIds.contains('thylacine') ? 1 : 0;
        }

        final isDone = current >= m.targetCount;
        updatedMissions[mEntry.key] = m.copyWith(
          currentProgress: current,
          isCompleted: isDone,
        );
      }
    }

    final nextState = state.copyWith(
      credits: state.credits + totalCreditsGen,
      dna: state.dna + totalDnaGen,
      research: state.research + totalResearchGen,
      habitats: updatedHabitats,
      expeditions: updatedExpeditions,
      missions: updatedMissions,
      totalDodosBred: state.totalDodosBred + totalNewAnimals,
      lastSavedTimestamp: nowMs,
    );

    return SimulationResult(
      nextState: nextState,
      creditsGenerated: totalCreditsGen,
      dnaGenerated: totalDnaGen,
      researchGenerated: totalResearchGen,
      animalsBorn: totalNewAnimals,
    );
  }
}
