class Species {
  final String id;
  final String name;
  final String scientificName;
  final String extinctionEra;
  final String habitatType;
  final String description;
  final int basePopulationCapacity;
  final double baseBreedingSeconds;
  final double baseFoodConsumptionPerSec;
  final double baseWaterConsumptionPerSec;
  final double baseDnaRatePerSec;
  final double baseResearchRatePerSec;
  final double baseCreditsRatePerSec;
  final String iconEmoji;

  const Species({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.extinctionEra,
    required this.habitatType,
    required this.description,
    required this.basePopulationCapacity,
    required this.baseBreedingSeconds,
    required this.baseFoodConsumptionPerSec,
    required this.baseWaterConsumptionPerSec,
    required this.baseDnaRatePerSec,
    required this.baseResearchRatePerSec,
    required this.baseCreditsRatePerSec,
    required this.iconEmoji,
  });

  static const Species dodo = Species(
    id: 'dodo',
    name: 'Dodo',
    scientificName: 'Raphus cucullatus',
    extinctionEra: 'c. 1662 (Mauritius)',
    habitatType: 'tropical_island',
    description:
        'A flightless bird endemic to Mauritius. Known for its docile nature and distinctive hooked beak, restored through ancient genetic recovery.',
    basePopulationCapacity: 25,
    baseBreedingSeconds: 15.0,
    baseFoodConsumptionPerSec: 0.05,
    baseWaterConsumptionPerSec: 0.05,
    baseDnaRatePerSec: 0.4,
    baseResearchRatePerSec: 0.25,
    baseCreditsRatePerSec: 1.0,
    iconEmoji: '🦤',
  );

  static const Species thylacine = Species(
    id: 'thylacine',
    name: 'Thylacine',
    scientificName: 'Thylacinus cynocephalus',
    extinctionEra: 'c. 1936 (Tasmania)',
    habitatType: 'australian_forest',
    description:
        'The Tasmanian Tiger, a legendary carnivorous marsupial with distinctive tiger-like dorsal stripes and a flexible pouch.',
    basePopulationCapacity: 20,
    baseBreedingSeconds: 22.0,
    baseFoodConsumptionPerSec: 0.08,
    baseWaterConsumptionPerSec: 0.06,
    baseDnaRatePerSec: 0.9,
    baseResearchRatePerSec: 0.60,
    baseCreditsRatePerSec: 2.5,
    iconEmoji: '🐺',
  );

  static const Species greatAuk = Species(
    id: 'great_auk',
    name: 'Great Auk',
    scientificName: 'Pinguinus impennis',
    extinctionEra: 'c. 1852 (North Atlantic)',
    habitatType: 'northern_coast',
    description:
        'A flightless, wing-propelled diving seabird of the North Atlantic. Agile swimmers in icy offshore waters.',
    basePopulationCapacity: 25,
    baseBreedingSeconds: 28.0,
    baseFoodConsumptionPerSec: 0.10,
    baseWaterConsumptionPerSec: 0.08,
    baseDnaRatePerSec: 1.6,
    baseResearchRatePerSec: 1.10,
    baseCreditsRatePerSec: 4.5,
    iconEmoji: '🐧',
  );

  static const Species quagga = Species(
    id: 'quagga',
    name: 'Quagga',
    scientificName: 'Equus quagga quagga',
    extinctionEra: 'c. 1883 (South Africa)',
    habitatType: 'african_grasslands',
    description:
        'A unique plains zebra sub-species with vivid stripes on its head and neck fading to chestnut brown across the torso.',
    basePopulationCapacity: 30,
    baseBreedingSeconds: 35.0,
    baseFoodConsumptionPerSec: 0.14,
    baseWaterConsumptionPerSec: 0.12,
    baseDnaRatePerSec: 2.8,
    baseResearchRatePerSec: 1.90,
    baseCreditsRatePerSec: 8.0,
    iconEmoji: '🦓',
  );

  static const Species aurochs = Species(
    id: 'aurochs',
    name: 'Aurochs',
    scientificName: 'Bos primigenius',
    extinctionEra: 'c. 1627 (Poland)',
    habitatType: 'european_woodland',
    description:
        'The colossal wild ancestor of domestic cattle that roamed prehistoric Europe, celebrated for its curved horns and immense strength.',
    basePopulationCapacity: 20,
    baseBreedingSeconds: 45.0,
    baseFoodConsumptionPerSec: 0.20,
    baseWaterConsumptionPerSec: 0.16,
    baseDnaRatePerSec: 4.5,
    baseResearchRatePerSec: 3.20,
    baseCreditsRatePerSec: 14.0,
    iconEmoji: '🐂',
  );

  static const Species woollyMammoth = Species(
    id: 'woolly_mammoth',
    name: 'Woolly Mammoth',
    scientificName: 'Mammuthus primigenius',
    extinctionEra: 'c. 4000 BP (Wrangel Island)',
    habitatType: 'ice_age_tundra',
    description:
        'The crowning giant of the Pleistocene epoch, shielded by dense shaggy fur and massive curving ivory tusks.',
    basePopulationCapacity: 15,
    baseBreedingSeconds: 65.0,
    baseFoodConsumptionPerSec: 0.35,
    baseWaterConsumptionPerSec: 0.25,
    baseDnaRatePerSec: 9.0,
    baseResearchRatePerSec: 6.50,
    baseCreditsRatePerSec: 30.0,
    iconEmoji: '🦣',
  );

  static Map<String, Species> registry = {
    'dodo': dodo,
    'thylacine': thylacine,
    'great_auk': greatAuk,
    'quagga': quagga,
    'aurochs': aurochs,
    'woolly_mammoth': woollyMammoth,
  };

  static Species fromId(String id) {
    return registry[id] ?? dodo;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'extinctionEra': extinctionEra,
        'habitatType': habitatType,
        'description': description,
        'basePopulationCapacity': basePopulationCapacity,
        'baseBreedingSeconds': baseBreedingSeconds,
        'baseFoodConsumptionPerSec': baseFoodConsumptionPerSec,
        'baseWaterConsumptionPerSec': baseWaterConsumptionPerSec,
        'baseDnaRatePerSec': baseDnaRatePerSec,
        'baseResearchRatePerSec': baseResearchRatePerSec,
        'baseCreditsRatePerSec': baseCreditsRatePerSec,
        'iconEmoji': iconEmoji,
      };

  factory Species.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    if (registry.containsKey(id)) {
      return registry[id]!;
    }
    return Species(
      id: id,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      extinctionEra: json['extinctionEra'] as String,
      habitatType: json['habitatType'] as String,
      description: json['description'] as String,
      basePopulationCapacity: json['basePopulationCapacity'] as int,
      baseBreedingSeconds: (json['baseBreedingSeconds'] as num).toDouble(),
      baseFoodConsumptionPerSec:
          (json['baseFoodConsumptionPerSec'] as num).toDouble(),
      baseWaterConsumptionPerSec:
          (json['baseWaterConsumptionPerSec'] as num).toDouble(),
      baseDnaRatePerSec: (json['baseDnaRatePerSec'] as num).toDouble(),
      baseResearchRatePerSec:
          (json['baseResearchRatePerSec'] as num).toDouble(),
      baseCreditsRatePerSec:
          (json['baseCreditsRatePerSec'] as num).toDouble(),
      iconEmoji: json['iconEmoji'] as String? ?? '🐾',
    );
  }
}
