import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/feedback/game_haptics.dart';
import '../core/offline/offline_manager.dart';
import '../core/save/save_service.dart';
import '../core/simulation/simulation_engine.dart';
import '../models/expedition.dart';
import '../models/fossil.dart';
import '../models/game_state.dart';
import '../models/habitat.dart';
import '../models/mission.dart';
import '../models/research_node.dart';
import '../models/staff.dart';
import '../models/upgrade.dart';

class GameNotifier extends Notifier<GameState> {
  late final SaveService _saveService;
  late final SimulationEngine _engine;
  late final OfflineManager _offlineManager;
  Timer? _tickTimer;
  Timer? _autoSaveTimer;

  OfflineReport? pendingOfflineReport;

  @override
  GameState build() {
    _saveService = SaveService();
    _engine = const SimulationEngine();
    _offlineManager = const OfflineManager();

    ref.onDispose(() {
      _tickTimer?.cancel();
      _autoSaveTimer?.cancel();
    });

    _initialize();
    return GameState.initial();
  }

  Future<void> _initialize() async {
    final saved = await _saveService.loadGame();
    if (saved != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final report = _offlineManager.calculateOfflineProgress(
        state: saved,
        currentTimestampMs: now,
      );

      if (report != null &&
          (report.animalsBorn > 0 ||
              report.creditsEarned > 5.0 ||
              report.dnaRecovered > 1.0)) {
        pendingOfflineReport = report;
        state = report.finalState;
      } else {
        state = saved.copyWith(lastSavedTimestamp: now);
      }
    }
    _startLoops();
  }

  void dismissOfflineReport() {
    pendingOfflineReport = null;
  }

  void _lightHaptic() {
    if (!state.hapticsEnabled) return;
    GameHaptics.light();
  }

  void _mediumHaptic() {
    if (!state.hapticsEnabled) return;
    GameHaptics.medium();
  }

  void _heavyHaptic() {
    if (!state.hapticsEnabled) return;
    GameHaptics.heavy();
  }

  void _restorationHaptic() {
    if (!state.hapticsEnabled) return;
    GameHaptics.restore();
  }

  void _startLoops() {
    _tickTimer?.cancel();
    _autoSaveTimer?.cancel();

    // 1-second simulation tick for active play
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      tickActive(1.0);
    });

    // Auto-save every 10 seconds
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveService.saveGame(state);
    });
  }

  void tickActive(double dt) {
    final res = _engine.tick(state: state, dt: dt);
    state = res.nextState;
  }

  // Active Habitat Switcher (World Map)
  void switchActiveHabitat(String habitatId) {
    if (state.habitats.containsKey(habitatId)) {
      state = state.copyWith(activeHabitatId: habitatId);
    }
  }

  // Active Care Actions
  bool feedHabitat(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    const cost = 5.0;
    if (state.credits < cost && state.credits > 0) {
      // Prevent soft-lock if very low
    } else if (state.credits >= cost) {
      state = state.copyWith(credits: state.credits - cost);
    }
    final updatedHabitats = Map<String, Habitat>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      food: habitat.maxFood,
      happiness: (habitat.happiness + 8.0).clamp(0.0, 100.0),
    );
    state = state.copyWith(habitats: updatedHabitats);
    _lightHaptic();
    return true;
  }

  bool waterHabitat(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    final updatedHabitats = Map<String, Habitat>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      water: habitat.maxWater,
      happiness: (habitat.happiness + 8.0).clamp(0.0, 100.0),
    );
    state = state.copyWith(habitats: updatedHabitats);
    _lightHaptic();
    return true;
  }

  bool petAnimals(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    final updatedHabitats = Map<String, Habitat>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      happiness: (habitat.happiness + 10.0).clamp(0.0, 100.0),
    );
    // Rewarding tapping: grants instant bonus
    state = state.copyWith(
      dna: state.dna + 0.5,
      credits: state.credits + 1.0,
      habitats: updatedHabitats,
    );
    _lightHaptic();
    return true;
  }

  // Revive an animal directly with DNA
  bool reviveSpecies(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    if (habitat.population >= habitat.capacity) return false;

    const dnaCost = 15.0;
    if (state.dna < dnaCost) return false;

    final updatedHabitats = Map<String, Habitat>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      population: habitat.population + 1,
    );

    state = state.copyWith(
      dna: state.dna - dnaCost,
      habitats: updatedHabitats,
      totalDodosBred: state.totalDodosBred + 1,
    );
    _mediumHaptic();
    return true;
  }

  // Upgrade Actions
  bool buyUpgrade(String upgradeId) {
    final upg = state.upgrades[upgradeId];
    if (upg == null || upg.isMaxed) return false;

    final cost = upg.currentCost;
    double newCredits = state.credits;
    double newDna = state.dna;
    double newResearch = state.research;

    switch (upg.currency) {
      case UpgradeCurrency.credits:
        if (newCredits < cost) return false;
        newCredits -= cost;
        break;
      case UpgradeCurrency.dna:
        if (newDna < cost) return false;
        newDna -= cost;
        break;
      case UpgradeCurrency.research:
        if (newResearch < cost) return false;
        newResearch -= cost;
        break;
    }

    final newLevel = upg.currentLevel + 1;
    final updatedUpgrades = Map<String, Upgrade>.from(state.upgrades);
    updatedUpgrades[upgradeId] = upg.copyWith(currentLevel: newLevel);

    var updatedHabitats = Map<String, Habitat>.from(state.habitats);
    double updatedOfflineCap = state.offlineCapSeconds;

    // Apply specific upgrade effects to active habitat
    final currentHab = updatedHabitats[state.activeHabitatId];
    if (upg.type == UpgradeType.habitatLevel && currentHab != null) {
      updatedHabitats[state.activeHabitatId] =
          currentHab.copyWith(level: currentHab.level + 1);
    } else if (upg.type == UpgradeType.autoFeeder && currentHab != null) {
      updatedHabitats[state.activeHabitatId] =
          currentHab.copyWith(hasAutoFeeder: true);
    } else if (upg.type == UpgradeType.autoWater && currentHab != null) {
      updatedHabitats[state.activeHabitatId] =
          currentHab.copyWith(hasAutoWater: true);
    } else if (upg.type == UpgradeType.offlineCap) {
      updatedOfflineCap += 7200.0; // +2 hours
    }

    state = state.copyWith(
      credits: newCredits,
      dna: newDna,
      research: newResearch,
      upgrades: updatedUpgrades,
      habitats: updatedHabitats,
      offlineCapSeconds: updatedOfflineCap,
    );

    _mediumHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Staff Actions
  bool hireOrUpgradeStaff(String staffId) {
    final staff = state.staff[staffId];
    if (staff == null) return false;

    final cost = staff.upgradeCost;
    if (state.credits < cost) return false;

    final updatedStaff = Map<String, StaffMember>.from(state.staff);
    updatedStaff[staffId] = staff.copyWith(level: staff.level + 1);

    state = state.copyWith(
      credits: state.credits - cost,
      staff: updatedStaff,
    );

    _mediumHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Research Actions
  bool unlockResearch(String nodeId) {
    final node = state.researchNodes[nodeId];
    if (node == null || node.isUnlocked) return false;

    for (final prereq in node.prerequisites) {
      final pNode = state.researchNodes[prereq];
      if (pNode == null || !pNode.isUnlocked) return false;
    }

    if (state.research < node.cost) return false;

    final updatedResearch = Map<String, ResearchNode>.from(state.researchNodes);
    updatedResearch[nodeId] = node.copyWith(isUnlocked: true);

    state = state.copyWith(
      research: state.research - node.cost,
      researchNodes: updatedResearch,
    );

    _mediumHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Expedition Actions (Phase 7 Exploration)
  bool startExpedition(String expeditionId) {
    final exp = state.expeditions[expeditionId];
    if (exp == null || exp.isActive) return false;

    if (state.credits < exp.creditsCost) return false;

    // Apply radar research or restoration perks to duration
    final radarUnlocked =
        state.researchNodes['expedition_radar']?.isUnlocked ?? false;
    final speedMult =
        state.expeditionSpeedMultiplier * (radarUnlocked ? 1.4 : 1.0);
    final effectiveDuration = exp.durationSeconds / speedMult;

    final updatedExp = exp.copyWith(
      isActive: true,
      startedTimestampMs: DateTime.now().millisecondsSinceEpoch,
      isCompleted: false,
      durationSeconds: effectiveDuration,
    );

    final updatedMap = Map<String, Expedition>.from(state.expeditions);
    updatedMap[expeditionId] = updatedExp;

    state = state.copyWith(
      credits: state.credits - exp.creditsCost,
      expeditions: updatedMap,
    );

    _mediumHaptic();
    _saveService.saveGame(state);
    return true;
  }

  bool claimExpedition(String expeditionId) {
    final exp = state.expeditions[expeditionId];
    if (exp == null || !exp.isCompleted) return false;

    double bonusDna = 0;
    double bonusResearch = 0;
    final updatedInventory = Map<String, FossilItem>.from(state.fossilInventory);

    for (final find in exp.possibleFinds) {
      bonusDna += find.dnaBonus;
      bonusResearch += find.researchBonus;

      final existing = updatedInventory[find.id];
      if (existing != null) {
        updatedInventory[find.id] =
            existing.copyWith(count: existing.count + find.count);
      } else {
        updatedInventory[find.id] = find;
      }
    }

    final updatedSpecies = List<String>.from(state.unlockedSpeciesIds);
    final updatedHabitats = Map<String, Habitat>.from(state.habitats);

    // If expedition unlocks a new species, unlock and create its regional habitat!
    if (exp.unlocksSpeciesId != null &&
        !updatedSpecies.contains(exp.unlocksSpeciesId)) {
      final sId = exp.unlocksSpeciesId!;
      updatedSpecies.add(sId);

      if (sId == 'thylacine' && !updatedHabitats.containsKey('tasman_forest')) {
        updatedHabitats['tasman_forest'] = const Habitat(
          id: 'tasman_forest',
          name: 'Tasmanian Forest Reserve',
          speciesId: 'thylacine',
          biomeType: 'australian_forest',
          level: 1,
          population: 1,
        );
      } else if (sId == 'great_auk' &&
          !updatedHabitats.containsKey('north_coast')) {
        updatedHabitats['north_coast'] = const Habitat(
          id: 'north_coast',
          name: 'Northern Skerries Reserve',
          speciesId: 'great_auk',
          biomeType: 'northern_coast',
          level: 1,
          population: 1,
        );
      } else if (sId == 'quagga' &&
          !updatedHabitats.containsKey('karoo_reserve')) {
        updatedHabitats['karoo_reserve'] = const Habitat(
          id: 'karoo_reserve',
          name: 'Karoo Plains Reserve',
          speciesId: 'quagga',
          biomeType: 'african_grasslands',
          level: 1,
          population: 1,
        );
      } else if (sId == 'woolly_mammoth' &&
          !updatedHabitats.containsKey('siberia_tundra')) {
        updatedHabitats['siberia_tundra'] = const Habitat(
          id: 'siberia_tundra',
          name: 'Ice Age Glacial Reserve',
          speciesId: 'woolly_mammoth',
          biomeType: 'ice_age_tundra',
          level: 1,
          population: 1,
        );
      }
    }

    // Reset expedition for future runs
    final updatedExpeditions = Map<String, Expedition>.from(state.expeditions);
    updatedExpeditions[expeditionId] = exp.copyWith(
      isActive: false,
      isCompleted: false,
      startedTimestampMs: null,
    );

    state = state.copyWith(
      dna: state.dna + bonusDna,
      research: state.research + bonusResearch,
      fossilInventory: updatedInventory,
      unlockedSpeciesIds: updatedSpecies,
      habitats: updatedHabitats,
      expeditions: updatedExpeditions,
      totalExpeditionsCompleted: state.totalExpeditionsCompleted + 1,
    );

    _heavyHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Ecosystem Restoration (Prestige - Phase 10)
  bool restoreEcosystem(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;

    final earnedPoints = habitat.calculateRestorationPoints();

    final updatedHabitats = Map<String, Habitat>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      level: 1,
      population: 1,
      breedingProgress: 0.0,
      happiness: 100.0,
      food: 100.0,
      water: 100.0,
      timesRestored: habitat.timesRestored + 1,
    );

    state = state.copyWith(
      restorationPoints: state.restorationPoints + earnedPoints,
      habitats: updatedHabitats,
    );

    _restorationHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Restoration Perks Purchase
  bool buyRestorationPerk(String perkKey) {
    final currentLevel = state.restorationPerks[perkKey] ?? 0;
    final cost = (currentLevel + 1) * 5; // 5, 10, 15, 20...
    if (state.restorationPoints < cost) return false;

    final updatedPerks = Map<String, int>.from(state.restorationPerks);
    updatedPerks[perkKey] = currentLevel + 1;

    state = state.copyWith(
      restorationPoints: state.restorationPoints - cost,
      restorationPerks: updatedPerks,
    );

    _mediumHaptic();
    _saveService.saveGame(state);
    return true;
  }

  // Mission Rewards Claim (Phase 11)
  bool claimMissionReward(String missionId) {
    final mission = state.missions[missionId];
    if (mission == null || !mission.isCompleted || mission.isClaimed) {
      return false;
    }

    double newCredits = state.credits;
    double newDna = state.dna;
    double newResearch = state.research;
    double newRestoration = state.restorationPoints;

    switch (mission.rewardType) {
      case MissionRewardType.credits:
        newCredits += mission.rewardAmount;
        break;
      case MissionRewardType.dna:
        newDna += mission.rewardAmount;
        break;
      case MissionRewardType.research:
        newResearch += mission.rewardAmount;
        break;
      case MissionRewardType.restorationPoints:
        newRestoration += mission.rewardAmount;
        break;
    }

    final updatedMissions = Map<String, Mission>.from(state.missions);
    updatedMissions[missionId] = mission.copyWith(isClaimed: true);

    state = state.copyWith(
      credits: newCredits,
      dna: newDna,
      research: newResearch,
      restorationPoints: newRestoration,
      missions: updatedMissions,
    );

    _heavyHaptic();
    _saveService.saveGame(state);
    return true;
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  void toggleHaptics() {
    state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
  }

  Future<void> resetGame() async {
    await _saveService.clearSave();
    state = GameState.initial();
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
