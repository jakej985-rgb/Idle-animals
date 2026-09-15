import 'habitat.dart';
import 'research_node.dart';
import 'staff.dart';
import 'upgrade.dart';

class GameState {
  final double credits;
  final double dna;
  final double research;
  final double restorationPoints;
  final int lastSavedTimestamp;
  final double offlineCapSeconds;
  final Map<String, Habitat> habitats;
  final Map<String, StaffMember> staff;
  final Map<String, Upgrade> upgrades;
  final Map<String, ResearchNode> researchNodes;
  final List<String> unlockedSpeciesIds;
  final int totalDodosBred;

  const GameState({
    required this.credits,
    required this.dna,
    required this.research,
    required this.restorationPoints,
    required this.lastSavedTimestamp,
    this.offlineCapSeconds = 7200.0, // 2 hours base
    required this.habitats,
    required this.staff,
    required this.upgrades,
    required this.researchNodes,
    required this.unlockedSpeciesIds,
    this.totalDodosBred = 1,
  });

  static GameState initial() {
    return GameState(
      credits: 60.0,
      dna: 10.0,
      research: 0.0,
      restorationPoints: 0.0,
      lastSavedTimestamp: DateTime.now().millisecondsSinceEpoch,
      offlineCapSeconds: 7200.0,
      habitats: {
        'dodo_island': const Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
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
          level: 0, // Not hired yet
          title: 'Habitat Caretaker',
          description:
              'Maintains habitat feeders, comforts animals, and increases breeding speed by +10% per level.',
          avatarEmoji: '🧑‍🌾',
        ),
      },
      upgrades: {
        'habitat_expansion': const Upgrade(
          id: 'habitat_expansion',
          title: 'Expand Island Reserve',
          description: 'Increases habitat population capacity by +10 and habitat level.',
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
          description: 'Soft island moss nests increase natural breeding rate by +15%.',
          type: UpgradeType.breedingSpeed,
          currency: UpgradeCurrency.dna,
          baseCost: 25.0,
          costMultiplier: 1.5,
          icon: '🪺',
        ),
        'dna_sequencer': const Upgrade(
          id: 'dna_sequencer',
          title: 'Portable DNA Sampler',
          description: 'Boosts passive DNA harvested per happy Dodo by +20%.',
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
          description: 'Shortens egg hatching cycles by 20%.',
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
      },
      unlockedSpeciesIds: ['dodo'],
      totalDodosBred: 1,
    );
  }

  GameState copyWith({
    double? credits,
    double? dna,
    double? research,
    double? restorationPoints,
    int? lastSavedTimestamp,
    double? offlineCapSeconds,
    Map<String, Habitat>? habitats,
    Map<String, StaffMember>? staff,
    Map<String, Upgrade>? upgrades,
    Map<String, ResearchNode>? researchNodes,
    List<String>? unlockedSpeciesIds,
    int? totalDodosBred,
  }) {
    return GameState(
      credits: credits ?? this.credits,
      dna: dna ?? this.dna,
      research: research ?? this.research,
      restorationPoints: restorationPoints ?? this.restorationPoints,
      lastSavedTimestamp: lastSavedTimestamp ?? this.lastSavedTimestamp,
      offlineCapSeconds: offlineCapSeconds ?? this.offlineCapSeconds,
      habitats: habitats ?? this.habitats,
      staff: staff ?? this.staff,
      upgrades: upgrades ?? this.upgrades,
      researchNodes: researchNodes ?? this.researchNodes,
      unlockedSpeciesIds: unlockedSpeciesIds ?? this.unlockedSpeciesIds,
      totalDodosBred: totalDodosBred ?? this.totalDodosBred,
    );
  }

  Map<String, dynamic> toJson() => {
        'credits': credits,
        'dna': dna,
        'research': research,
        'restorationPoints': restorationPoints,
        'lastSavedTimestamp': lastSavedTimestamp,
        'offlineCapSeconds': offlineCapSeconds,
        'habitats': habitats.map((k, v) => MapEntry(k, v.toJson())),
        'staff': staff.map((k, v) => MapEntry(k, v.toJson())),
        'upgrades': upgrades.map((k, v) => MapEntry(k, v.toJson())),
        'researchNodes': researchNodes.map((k, v) => MapEntry(k, v.toJson())),
        'unlockedSpeciesIds': unlockedSpeciesIds,
        'totalDodosBred': totalDodosBred,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      credits: (json['credits'] as num?)?.toDouble() ?? 60.0,
      dna: (json['dna'] as num?)?.toDouble() ?? 10.0,
      research: (json['research'] as num?)?.toDouble() ?? 0.0,
      restorationPoints:
          (json['restorationPoints'] as num?)?.toDouble() ?? 0.0,
      lastSavedTimestamp: (json['lastSavedTimestamp'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
      offlineCapSeconds:
          (json['offlineCapSeconds'] as num?)?.toDouble() ?? 7200.0,
      habitats: (json['habitats'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Habitat.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      staff: (json['staff'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, StaffMember.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      upgrades: (json['upgrades'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Upgrade.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      researchNodes: (json['researchNodes'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, ResearchNode.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      unlockedSpeciesIds:
          (json['unlockedSpeciesIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['dodo'],
      totalDodosBred: json['totalDodosBred'] as int? ?? 1,
    );
  }
}
