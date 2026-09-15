class Habitat {
  final String id;
  final String name;
  final String speciesId;
  final String biomeType;
  final int level;
  final int population;
  final double breedingProgress; // 0.0 to 1.0
  final double food;
  final double maxFood;
  final double water;
  final double maxWater;
  final double happiness; // 0.0 to 100.0
  final bool hasAutoFeeder;
  final bool hasAutoWater;
  final int timesRestored;

  const Habitat({
    required this.id,
    required this.name,
    required this.speciesId,
    this.biomeType = 'tropical_island',
    this.level = 1,
    this.population = 1,
    this.breedingProgress = 0.0,
    this.food = 100.0,
    this.maxFood = 100.0,
    this.water = 100.0,
    this.maxWater = 100.0,
    this.happiness = 100.0,
    this.hasAutoFeeder = false,
    this.hasAutoWater = false,
    this.timesRestored = 0,
  });

  int get capacity => 20 + (level * 10);

  double get foodPercentage => (food / maxFood).clamp(0.0, 1.0);
  double get waterPercentage => (water / maxWater).clamp(0.0, 1.0);
  double get happinessMultiplier => (happiness / 100.0).clamp(0.2, 1.5);

  // Prestige / Ecosystem Restoration points calculation
  int calculateRestorationPoints() {
    final popBonus = (population / 4).floor();
    final levelBonus = level * 3;
    final base = popBonus + levelBonus;
    return base < 5 ? 5 : base;
  }

  Habitat copyWith({
    String? id,
    String? name,
    String? speciesId,
    String? biomeType,
    int? level,
    int? population,
    double? breedingProgress,
    double? food,
    double? maxFood,
    double? water,
    double? maxWater,
    double? happiness,
    bool? hasAutoFeeder,
    bool? hasAutoWater,
    int? timesRestored,
  }) {
    return Habitat(
      id: id ?? this.id,
      name: name ?? this.name,
      speciesId: speciesId ?? this.speciesId,
      biomeType: biomeType ?? this.biomeType,
      level: level ?? this.level,
      population: population ?? this.population,
      breedingProgress: breedingProgress ?? this.breedingProgress,
      food: food ?? this.food,
      maxFood: maxFood ?? this.maxFood,
      water: water ?? this.water,
      maxWater: maxWater ?? this.maxWater,
      happiness: happiness ?? this.happiness,
      hasAutoFeeder: hasAutoFeeder ?? this.hasAutoFeeder,
      hasAutoWater: hasAutoWater ?? this.hasAutoWater,
      timesRestored: timesRestored ?? this.timesRestored,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'speciesId': speciesId,
        'biomeType': biomeType,
        'level': level,
        'population': population,
        'breedingProgress': breedingProgress,
        'food': food,
        'maxFood': maxFood,
        'water': water,
        'maxWater': maxWater,
        'happiness': happiness,
        'hasAutoFeeder': hasAutoFeeder,
        'hasAutoWater': hasAutoWater,
        'timesRestored': timesRestored,
      };

  factory Habitat.fromJson(Map<String, dynamic> json) {
    return Habitat(
      id: json['id'] as String,
      name: json['name'] as String,
      speciesId: json['speciesId'] as String,
      biomeType: json['biomeType'] as String? ?? 'tropical_island',
      level: json['level'] as int? ?? 1,
      population: json['population'] as int? ?? 1,
      breedingProgress:
          (json['breedingProgress'] as num?)?.toDouble() ?? 0.0,
      food: (json['food'] as num?)?.toDouble() ?? 100.0,
      maxFood: (json['maxFood'] as num?)?.toDouble() ?? 100.0,
      water: (json['water'] as num?)?.toDouble() ?? 100.0,
      maxWater: (json['maxWater'] as num?)?.toDouble() ?? 100.0,
      happiness: (json['happiness'] as num?)?.toDouble() ?? 100.0,
      hasAutoFeeder: json['hasAutoFeeder'] as bool? ?? false,
      hasAutoWater: json['hasAutoWater'] as bool? ?? false,
      timesRestored: json['timesRestored'] as int? ?? 0,
    );
  }
}
