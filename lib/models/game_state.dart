import 'expedition.dart';
import 'fossil.dart';
import 'habitat.dart';
import 'mission.dart';
import 'research_node.dart';
import 'staff.dart';
import 'upgrade.dart';

class GameState {
  static const int currentSchemaVersion = 2;

  final int schemaVersion;
  final double credits;
  final double dna;
  final double research;
  final double restorationPoints;
  final int lastSavedTimestamp;
  final double offlineCapSeconds;
  final String activeHabitatId;
  final Map<String, Habitat> habitats;
  final Map<String, StaffMember> staff;
  final Map<String, Upgrade> upgrades;
  final Map<String, ResearchNode> researchNodes;
  final Map<String, Expedition> expeditions;
  final Map<String, FossilItem> fossilInventory;
  final Map<String, Mission> missions;
  final Map<String, int> restorationPerks;
  final List<String> unlockedSpeciesIds;
  final int totalAnimalsBred;
  int get totalDodosBred => totalAnimalsBred;
  final int totalExpeditionsCompleted;
  final bool soundEnabled;
  final bool hapticsEnabled;

  const GameState({
    this.schemaVersion = currentSchemaVersion,
    required this.credits,
    required this.dna,
    required this.research,
    required this.restorationPoints,
    required this.lastSavedTimestamp,
    this.offlineCapSeconds = 7200.0, // 2 hours base
    this.activeHabitatId = 'dodo_island',
    required this.habitats,
    required this.staff,
    required this.upgrades,
    required this.researchNodes,
    required this.expeditions,
    required this.fossilInventory,
    required this.missions,
    required this.restorationPerks,
    required this.unlockedSpeciesIds,
    this.totalAnimalsBred = 1,
    this.totalExpeditionsCompleted = 0,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  /// The habitat the player is caring for. Every loader routes
  /// [activeHabitatId] through a habitat the state actually has, so the active
  /// id and this habitat cannot disagree.
  Habitat get activeHabitat => habitats[activeHabitatId]!;

  // Permanent restoration multipliers
  double get globalGrowthMultiplier =>
      1.0 + ((restorationPerks['growth_boost'] ?? 0) * 0.15);

  double get globalDnaMultiplier =>
      1.0 + ((restorationPerks['dna_boost'] ?? 0) * 0.20);

  double get globalResearchMultiplier =>
      1.0 + ((restorationPerks['research_boost'] ?? 0) * 0.20);

  double get expeditionSpeedMultiplier =>
      1.0 + ((restorationPerks['expedition_boost'] ?? 0) * 0.25);

  static GameState initial() {
    final defaultExps = Expedition.defaultExpeditions();
    final defaultMissionsList = Mission.defaultMissions();

    return GameState(
      credits: 60.0,
      dna: 10.0,
      research: 0.0,
      restorationPoints: 0.0,
      lastSavedTimestamp: DateTime.now().millisecondsSinceEpoch,
      offlineCapSeconds: 7200.0,
      activeHabitatId: 'dodo_island',
      habitats: {
        'dodo_island': const Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
          biomeType: 'tropical_island',
          level: 1,
          population: 1,
          food: 100.0,
          maxFood: 100.0,
          water: 100.0,
          maxWater: 100.0,
          happiness: 100.0,
        ),
      },
      staff: {
        'keeper': const StaffMember(
          id: 'keeper',
          name: 'Sarah the Keeper',
          role: StaffRole.keeper,
          level: 0,
          title: 'Habitat Caretaker',
          description: 'Maintains habitat feeders, comforts animals, and increases breeding speed by +10% per level.',
          avatarEmoji: '🧑‍🌾',
        ),
      },
      upgrades: {
        'habitat_expansion': const Upgrade(
          id: 'habitat_expansion',
          title: 'Expand Island Reserve',
          description:
              'Increases active habitat capacity by +10 and habitat level.',
          type: UpgradeType.habitatLevel,
          currency: UpgradeCurrency.credits,
          baseCost: 50.0,
          costMultiplier: 1.8,
          icon: '🏝️',
        ),
        'auto_feeder': const Upgrade(
          id: 'auto_feeder',
          title: 'Solar Automated Feeder',
          description: 'Automatically restocks island fruit troughs when food dips below 25%.',
          type: UpgradeType.autoFeeder,
          currency: UpgradeCurrency.credits,
          baseCost: 150.0,
          maxLevel: 1,
          icon: '🥣',
        ),
        'auto_water': const Upgrade(
          id: 'auto_water',
          title: 'Spring Fresh-Flow Pump',
          description: 'Continuously channels clean freshwater directly to drinking pools.',
          type: UpgradeType.autoWater,
          currency: UpgradeCurrency.credits,
          baseCost: 200.0,
          maxLevel: 1,
          icon: '💧',
        ),
        'breeding_ground': const Upgrade(
          id: 'breeding_ground',
          title: 'Protected Nesting Grounds',
          description:
              'Soft island moss nests increase natural breeding rate by +15%.',
          type: UpgradeType.breedingSpeed,
          currency: UpgradeCurrency.dna,
          baseCost: 25.0,
          costMultiplier: 1.5,
          icon: '🪺',
        ),
        'dna_sequencer': const Upgrade(
          id: 'dna_sequencer',
          title: 'Portable DNA Sampler',
          description: 'Boosts passive DNA harvested per happy animal by +20%.',
          type: UpgradeType.dnaExtraction,
          currency: UpgradeCurrency.research,
          baseCost: 20.0,
          costMultiplier: 1.6,
          icon: '🧬',
        ),
        'offline_storage': const Upgrade(
          id: 'offline_storage',
          title: 'Automated Care Log',
          description: 'Expands offline earnings simulation cap by +2 hours.',
          type: UpgradeType.offlineCap,
          currency: UpgradeCurrency.credits,
          baseCost: 100.0,
          costMultiplier: 2.0,
          maxLevel: 4,
          icon: '⏳',
        ),
      },
      researchNodes: {
        'incubation': const ResearchNode(
          id: 'incubation',
          title: 'Accelerated Incubation',
          description: 'Shortens egg hatching and birth cycles by 20%.',
          cost: 15.0,
          icon: '🥚',
        ),
        'nutrition': const ResearchNode(
          id: 'nutrition',
          title: 'High-Energy Island Flora',
          description: 'Specialized seeds halve food consumption rate.',
          cost: 35.0,
          prerequisites: ['incubation'],
          icon: '🌿',
        ),
        'ancient_dna': const ResearchNode(
          id: 'ancient_dna',
          title: 'Ancient Genetics Synthesis',
          description: 'Increases DNA recovery rates across all sanctuary habitats by +50%.',
          cost: 75.0,
          prerequisites: ['nutrition'],
          icon: '🧬',
        ),
        'expedition_radar': const ResearchNode(
          id: 'expedition_radar',
          title: 'Ground-Penetrating Radar',
          description: 'Cuts all expedition travel times by 30%.',
          cost: 110.0,
          prerequisites: ['ancient_dna'],
          icon: '📡',
        ),
      },
      expeditions: {for (var e in defaultExps) e.id: e},
      fossilInventory: {},
      missions: {for (var m in defaultMissionsList) m.id: m},
      restorationPerks: {
        'growth_boost': 0,
        'dna_boost': 0,
        'research_boost': 0,
        'expedition_boost': 0,
      },
      unlockedSpeciesIds: ['dodo'],
      totalAnimalsBred: 1,
      totalExpeditionsCompleted: 0,
      soundEnabled: true,
      hapticsEnabled: true,
    );
  }

  GameState copyWith({
    int? schemaVersion,
    double? credits,
    double? dna,
    double? research,
    double? restorationPoints,
    int? lastSavedTimestamp,
    double? offlineCapSeconds,
    String? activeHabitatId,
    Map<String, Habitat>? habitats,
    Map<String, StaffMember>? staff,
    Map<String, Upgrade>? upgrades,
    Map<String, ResearchNode>? researchNodes,
    Map<String, Expedition>? expeditions,
    Map<String, FossilItem>? fossilInventory,
    Map<String, Mission>? missions,
    Map<String, int>? restorationPerks,
    List<String>? unlockedSpeciesIds,
    int? totalAnimalsBred,
    int? totalDodosBred,
    int? totalExpeditionsCompleted,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return GameState(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      credits: credits ?? this.credits,
      dna: dna ?? this.dna,
      research: research ?? this.research,
      restorationPoints: restorationPoints ?? this.restorationPoints,
      lastSavedTimestamp: lastSavedTimestamp ?? this.lastSavedTimestamp,
      offlineCapSeconds: offlineCapSeconds ?? this.offlineCapSeconds,
      activeHabitatId: activeHabitatId ?? this.activeHabitatId,
      habitats: habitats ?? this.habitats,
      staff: staff ?? this.staff,
      upgrades: upgrades ?? this.upgrades,
      researchNodes: researchNodes ?? this.researchNodes,
      expeditions: expeditions ?? this.expeditions,
      fossilInventory: fossilInventory ?? this.fossilInventory,
      missions: missions ?? this.missions,
      restorationPerks: restorationPerks ?? this.restorationPerks,
      unlockedSpeciesIds: unlockedSpeciesIds ?? this.unlockedSpeciesIds,
      totalAnimalsBred:
          totalAnimalsBred ?? totalDodosBred ?? this.totalAnimalsBred,
      totalExpeditionsCompleted:
          totalExpeditionsCompleted ?? this.totalExpeditionsCompleted,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': currentSchemaVersion,
    'credits': credits,
    'dna': dna,
    'research': research,
    'restorationPoints': restorationPoints,
    'lastSavedTimestamp': lastSavedTimestamp,
    'offlineCapSeconds': offlineCapSeconds,
    'activeHabitatId': activeHabitatId,
    'habitats': habitats.map((k, v) => MapEntry(k, v.toJson())),
    'staff': staff.map((k, v) => MapEntry(k, v.toJson())),
    'upgrades': upgrades.map((k, v) => MapEntry(k, v.toJson())),
    'researchNodes': researchNodes.map((k, v) => MapEntry(k, v.toJson())),
    'expeditions': expeditions.map((k, v) => MapEntry(k, v.toJson())),
    'fossilInventory': fossilInventory.map((k, v) => MapEntry(k, v.toJson())),
    'missions': missions.map((k, v) => MapEntry(k, v.toJson())),
    'restorationPerks': restorationPerks,
    'unlockedSpeciesIds': unlockedSpeciesIds,
    'totalAnimalsBred': totalAnimalsBred,
    'totalDodosBred': totalAnimalsBred, // Backwards compatibility for v1
    'totalExpeditionsCompleted': totalExpeditionsCompleted,
    'soundEnabled': soundEnabled,
    'hapticsEnabled': hapticsEnabled,
  };

  /// Payload upgrades, keyed by the version they start from and each returning
  /// the payload for `version + 1`.
  ///
  /// v1 needs no rewrite - the parser reads the v1 names and defaults every
  /// field v2 added - but the entry keeps the step explicit so the next schema
  /// change has somewhere to live instead of being invented under pressure.
  static const Map<int, Map<String, dynamic> Function(Map<String, dynamic>)>
  _migrations = {1: _migrateV1ToV2};

  static Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> json) =>
      Map<String, dynamic>.from(json);

  factory GameState.fromJson(Map<String, dynamic> json) {
    var data = Map<String, dynamic>.from(json);
    final storedVersion = (data['schemaVersion'] as int?) ?? 1;
    // A version below the first schema would otherwise walk the migration loop
    // one step per integer up to the current one - for a negative version that
    // is billions of iterations on the main thread.
    final version = storedVersion < 1 ? 1 : storedVersion;
    for (var from = version; from < currentSchemaVersion; from++) {
      final migrate = _migrations[from];
      if (migrate != null) data = migrate(data);
    }
    // A payload from a newer build is read as far as the parser understands it
    // rather than rejected, and keeps its own version so nothing pretends it
    // was migrated back.
    data['schemaVersion'] = version > currentSchemaVersion
        ? version
        : currentSchemaVersion;
    return _fromV2Json(data);
  }

  static GameState _fromV2Json(Map<String, dynamic> json) {
    // A payload without habitats is not a playable game: callers read the
    // active habitat, so it is rejected as unreadable (and recovered from the
    // backup) rather than loaded and throwing on every launch.
    final savedHabitats = json['habitats'];
    if (savedHabitats is! Map || savedHabitats.isEmpty) {
      throw const FormatException('the save has no habitats');
    }

    final habitats = (savedHabitats as Map<String, dynamic>).map((k, v) {
      final habitat = Habitat.fromJson(v as Map<String, dynamic>);
      // The map key is authoritative: older saves can omit the id and a stale
      // one can disagree with the key. Care actions look habitats up by `id`,
      // not by the map key, so it must match.
      return MapEntry(k, habitat.copyWith(id: k));
    });

    // The active id must name a habitat this save actually has: care actions
    // and upgrades address the active habitat by that id, so a stale one makes
    // them silently do nothing. Fall back to a habitat that is here.
    final requestedActive = json['activeHabitatId'] as String?;
    final activeHabitatId =
        requestedActive != null && habitats.containsKey(requestedActive)
        ? requestedActive
        : habitats.keys.first;

    // Migration: If v1, totalAnimalsBred falls back to totalDodosBred
    final totalBred =
        json['totalAnimalsBred'] as int? ?? json['totalDodosBred'] as int? ?? 1;

    return GameState(
      schemaVersion: json['schemaVersion'] as int? ?? currentSchemaVersion,
      credits: (json['credits'] as num?)?.toDouble() ?? 60.0,
      dna: (json['dna'] as num?)?.toDouble() ?? 10.0,
      research: (json['research'] as num?)?.toDouble() ?? 0.0,
      restorationPoints: (json['restorationPoints'] as num?)?.toDouble() ?? 0.0,
      lastSavedTimestamp:
          (json['lastSavedTimestamp'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
      offlineCapSeconds:
          (json['offlineCapSeconds'] as num?)?.toDouble() ?? 7200.0,
      activeHabitatId: activeHabitatId,
      habitats: habitats,
      staff:
          (json['staff'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, StaffMember.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      upgrades:
          (json['upgrades'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Upgrade.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      researchNodes:
          (json['researchNodes'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, ResearchNode.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      expeditions:
          (json['expeditions'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, Expedition.fromJson(v as Map<String, dynamic>)),
          ) ??
          {for (var e in Expedition.defaultExpeditions()) e.id: e},
      fossilInventory:
          (json['fossilInventory'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, FossilItem.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      missions:
          (json['missions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Mission.fromJson(v as Map<String, dynamic>)),
          ) ??
          {for (var m in Mission.defaultMissions()) m.id: m},
      restorationPerks:
          (json['restorationPerks'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {
            'growth_boost': 0,
            'dna_boost': 0,
            'research_boost': 0,
            'expedition_boost': 0,
          },
      unlockedSpeciesIds:
          (json['unlockedSpeciesIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['dodo'],
      totalAnimalsBred: totalBred,
      totalExpeditionsCompleted: json['totalExpeditionsCompleted'] as int? ?? 0,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }
}
