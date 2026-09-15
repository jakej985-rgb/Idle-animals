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
        'A flightless bird endemic to Mauritius. Known for its docile nature and distinctive beak, restored through ancient genetic recovery.',
    basePopulationCapacity: 25,
    baseBreedingSeconds: 15.0,
    baseFoodConsumptionPerSec: 0.05,
    baseWaterConsumptionPerSec: 0.05,
    baseDnaRatePerSec: 0.4,
    baseResearchRatePerSec: 0.25,
    baseCreditsRatePerSec: 1.0,
    iconEmoji: '🦤',
  );

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
    if (json['id'] == 'dodo') return dodo;
    return Species(
      id: json['id'] as String,
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
