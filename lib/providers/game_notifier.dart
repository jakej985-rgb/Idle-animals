import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/offline/offline_manager.dart';
import '../core/save/save_service.dart';
import '../core/simulation/simulation_engine.dart';
import '../models/game_state.dart';
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
          (report.dodosBorn > 0 ||
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

  // Active Care Actions
  bool feedHabitat(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    final cost = 5.0;
    if (state.credits < cost && state.credits > 0) {
      // Allow feeding even if low on credits to prevent soft-locks
    } else if (state.credits >= cost) {
      state = state.copyWith(credits: state.credits - cost);
    }
    final updatedHabitats = Map<String, dynamic>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      food: habitat.maxFood,
      happiness: (habitat.happiness + 8.0).clamp(0.0, 100.0),
    );
    state = state.copyWith(
      habitats: updatedHabitats.cast(),
    );
    return true;
  }

  bool waterHabitat(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    final updatedHabitats = Map<String, dynamic>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      water: habitat.maxWater,
      happiness: (habitat.happiness + 8.0).clamp(0.0, 100.0),
    );
    state = state.copyWith(
      habitats: updatedHabitats.cast(),
    );
    return true;
  }

  bool petDodos(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    final updatedHabitats = Map<String, dynamic>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      happiness: (habitat.happiness + 10.0).clamp(0.0, 100.0),
    );
    // Rewarding tapping: grants instant +0.5 DNA and +1 credit
    state = state.copyWith(
      dna: state.dna + 0.5,
      credits: state.credits + 1.0,
      habitats: updatedHabitats.cast(),
    );
    return true;
  }

  // Revive an extra Dodo directly with DNA
  bool reviveDodo(String habitatId) {
    final habitat = state.habitats[habitatId];
    if (habitat == null) return false;
    if (habitat.population >= habitat.capacity) return false;

    const dnaCost = 15.0;
    if (state.dna < dnaCost) return false;

    final updatedHabitats = Map<String, dynamic>.from(state.habitats);
    updatedHabitats[habitatId] = habitat.copyWith(
      population: habitat.population + 1,
    );

    state = state.copyWith(
      dna: state.dna - dnaCost,
      habitats: updatedHabitats.cast(),
      totalDodosBred: state.totalDodosBred + 1,
    );
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

    var updatedHabitats = Map<String, dynamic>.from(state.habitats);
    double updatedOfflineCap = state.offlineCapSeconds;

    // Apply specific upgrade effects
    if (upg.type == UpgradeType.habitatLevel) {
      final h = updatedHabitats['dodo_island'];
      if (h != null) {
        updatedHabitats['dodo_island'] = h.copyWith(level: h.level + 1);
      }
    } else if (upg.type == UpgradeType.autoFeeder) {
      final h = updatedHabitats['dodo_island'];
      if (h != null) {
        updatedHabitats['dodo_island'] = h.copyWith(hasAutoFeeder: true);
      }
    } else if (upg.type == UpgradeType.autoWater) {
      final h = updatedHabitats['dodo_island'];
      if (h != null) {
        updatedHabitats['dodo_island'] = h.copyWith(hasAutoWater: true);
      }
    } else if (upg.type == UpgradeType.offlineCap) {
      updatedOfflineCap += 7200.0; // +2 hours
    }

    state = state.copyWith(
      credits: newCredits,
      dna: newDna,
      research: newResearch,
      upgrades: updatedUpgrades,
      habitats: updatedHabitats.cast(),
      offlineCapSeconds: updatedOfflineCap,
    );

    _saveService.saveGame(state);
    return true;
  }

  // Staff Actions
  bool hireOrUpgradeStaff(String staffId) {
    final staff = state.staff[staffId];
    if (staff == null) return false;

    final cost = staff.upgradeCost;
    if (state.credits < cost) return false;

    final updatedStaff = Map<String, dynamic>.from(state.staff);
    updatedStaff[staffId] = staff.copyWith(level: staff.level + 1);

    state = state.copyWith(
      credits: state.credits - cost,
      staff: updatedStaff.cast(),
    );

    _saveService.saveGame(state);
    return true;
  }

  // Research Actions
  bool unlockResearch(String nodeId) {
    final node = state.researchNodes[nodeId];
    if (node == null || node.isUnlocked) return false;

    // Check prerequisites
    for (final prereq in node.prerequisites) {
      final pNode = state.researchNodes[prereq];
      if (pNode == null || !pNode.isUnlocked) return false;
    }

    if (state.research < node.cost) return false;

    final updatedResearch = Map<String, dynamic>.from(state.researchNodes);
    updatedResearch[nodeId] = node.copyWith(isUnlocked: true);

    state = state.copyWith(
      research: state.research - node.cost,
      researchNodes: updatedResearch.cast(),
    );

    _saveService.saveGame(state);
    return true;
  }

  Future<void> resetGame() async {
    await _saveService.clearSave();
    state = GameState.initial();
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
