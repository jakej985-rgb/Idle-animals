import 'fossil.dart';

class Expedition {
  final String id;
  final String name;
  final String region;
  final String description;
  final double durationSeconds;
  final double creditsCost;
  final String iconEmoji;
  final String? unlocksSpeciesId;
  final List<FossilItem> possibleFinds;

  // Runtime active state
  final bool isActive;
  final int? startedTimestampMs;
  final bool isCompleted;

  const Expedition({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.durationSeconds,
    required this.creditsCost,
    required this.iconEmoji,
    this.unlocksSpeciesId,
    this.possibleFinds = const [],
    this.isActive = false,
    this.startedTimestampMs,
    this.isCompleted = false,
  });

  double getRemainingSeconds(int nowMs) {
    if (!isActive || startedTimestampMs == null) return 0;
    final elapsedSec = (nowMs - startedTimestampMs!) / 1000.0;
    final rem = durationSeconds - elapsedSec;
    return rem < 0 ? 0 : rem;
  }

  bool checkCompleted(int nowMs) {
    if (!isActive || startedTimestampMs == null) return false;
    final elapsedSec = (nowMs - startedTimestampMs!) / 1000.0;
    return elapsedSec >= durationSeconds;
  }

  Expedition copyWith({
    bool? isActive,
    int? startedTimestampMs,
    bool? isCompleted,
    double? durationSeconds,
  }) {
    return Expedition(
      id: id,
      name: name,
      region: region,
      description: description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      creditsCost: creditsCost,
      iconEmoji: iconEmoji,
      unlocksSpeciesId: unlocksSpeciesId,
      possibleFinds: possibleFinds,
      isActive: isActive ?? this.isActive,
      startedTimestampMs: startedTimestampMs ?? this.startedTimestampMs,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'region': region,
    'description': description,
    'durationSeconds': durationSeconds,
    'creditsCost': creditsCost,
    'iconEmoji': iconEmoji,
    'unlocksSpeciesId': unlocksSpeciesId,
    'possibleFinds': possibleFinds.map((f) => f.toJson()).toList(),
    'isActive': isActive,
    'startedTimestampMs': startedTimestampMs,
    'isCompleted': isCompleted,
  };

  factory Expedition.fromJson(Map<String, dynamic> json) {
    return Expedition(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      description: json['description'] as String,
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      creditsCost: (json['creditsCost'] as num).toDouble(),
      iconEmoji: json['iconEmoji'] as String? ?? '🗺️',
      unlocksSpeciesId: json['unlocksSpeciesId'] as String?,
      possibleFinds:
          (json['possibleFinds'] as List<dynamic>?)
              ?.map((e) => FossilItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? false,
      startedTimestampMs: json['startedTimestampMs'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static List<Expedition> defaultExpeditions() {
    return [
      const Expedition(
        id: 'fossil_basin',
        name: 'Fossil Basin Recon',
        region: 'Tropical Shoreline',
        description: 'Scout limestone caves for prehistoric shellfish and mineralized dodo bones.',
        durationSeconds: 30.0,
        creditsCost: 40.0,
        iconEmoji: '🏜️',
        possibleFinds: [
          FossilItem(
            id: 'dodo_bone',
            name: 'Pristine Dodo Sternum',
            description: 'Rare flightless bird keel bone packed with recoverable genetic strands.',
            rarity: FossilRarity.uncommon,
            iconEmoji: '🦴',
            dnaBonus: 20.0,
            researchBonus: 10.0,
          ),
          FossilItem(
            id: 'amber_fragment',
            name: 'Ancient Pine Amber',
            description: 'Translucent fossilized resin with prehistoric micro-particles.',
            rarity: FossilRarity.common,
            iconEmoji: '💎',
            dnaBonus: 10.0,
            researchBonus: 15.0,
          ),
        ],
      ),
      const Expedition(
        id: 'tasman_outback',
        name: 'Tasmanian Wilderness',
        region: 'Australian Forest',
        description: 'Trek through dense eucalyptus woodlands in search of Thylacine genetic trails.',
        durationSeconds: 60.0,
        creditsCost: 120.0,
        iconEmoji: '🌲',
        unlocksSpeciesId: 'thylacine',
        possibleFinds: [
          FossilItem(
            id: 'thylacine_skull',
            name: 'Tasmanian Tiger Canine',
            description: 'Carnivorous marsupial jaw fragment with well-preserved pulp cavity DNA.',
            rarity: FossilRarity.rare,
            iconEmoji: '🦷',
            dnaBonus: 40.0,
            researchBonus: 25.0,
          ),
        ],
      ),
      const Expedition(
        id: 'north_atlantic_cliffs',
        name: 'Eldey Coastal Skerries',
        region: 'Northern Coast',
        description: 'Braving cold offshore ocean cliffs where colonies of the Great Auk once nested.',
        durationSeconds: 90.0,
        creditsCost: 220.0,
        iconEmoji: '🌊',
        unlocksSpeciesId: 'great_auk',
        possibleFinds: [
          FossilItem(
            id: 'auk_egg_shell',
            name: 'Sub-fossil Auk Eggshell',
            description: 'Speckled seabird egg fragments bearing preserved nuclear genomic material.',
            rarity: FossilRarity.rare,
            iconEmoji: '🥚',
            dnaBonus: 60.0,
            researchBonus: 40.0,
          ),
        ],
      ),
      const Expedition(
        id: 'karoo_plains',
        name: 'Great Karoo Basin',
        region: 'African Grasslands',
        description: 'Survey dry riverbeds in South Africa for zebra cousin Quagga skeletal remnants.',
        durationSeconds: 120.0,
        creditsCost: 380.0,
        iconEmoji: '🌾',
        unlocksSpeciesId: 'quagga',
        possibleFinds: [
          FossilItem(
            id: 'quagga_hoof',
            name: 'Equid Hoof Core',
            description: 'Mineralized fossil hoof with extractable equine mitochondrial genes.',
            rarity: FossilRarity.rare,
            iconEmoji: '🐎',
            dnaBonus: 90.0,
            researchBonus: 60.0,
          ),
        ],
      ),
      const Expedition(
        id: 'siberian_ice_sheet',
        name: 'Wrangel Glacial Permafrost',
        region: 'Ice Age Tundra',
        description: 'Deep core drilling through arctic ice to unearth intact mammoth soft tissue.',
        durationSeconds: 180.0,
        creditsCost: 750.0,
        iconEmoji: '❄️',
        unlocksSpeciesId: 'woolly_mammoth',
        possibleFinds: [
          FossilItem(
            id: 'mammoth_tusk',
            name: 'Giant Curved Ivory Tusk',
            description: 'Enormous woolly mammoth tusk containing high-yield ancient genetic strands.',
            rarity: FossilRarity.legendary,
            iconEmoji: '🦣',
            dnaBonus: 180.0,
            researchBonus: 120.0,
          ),
        ],
      ),
    ];
  }
}
