enum UpgradeCurrency {
  credits,
  dna,
  research,
}

enum UpgradeType {
  habitatLevel,
  autoFeeder,
  autoWater,
  offlineCap,
  breedingSpeed,
  dnaExtraction,
}

class Upgrade {
  final String id;
  final String title;
  final String description;
  final UpgradeType type;
  final UpgradeCurrency currency;
  final double baseCost;
  final double costMultiplier;
  final int currentLevel;
  final int maxLevel;
  final String icon;

  const Upgrade({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.currency,
    required this.baseCost,
    this.costMultiplier = 1.6,
    this.currentLevel = 0,
    this.maxLevel = 10,
    required this.icon,
  });

  bool get isMaxed => currentLevel >= maxLevel;

  double get currentCost => baseCost * (currentLevel == 0 ? 1.0 : (costMultiplier * currentLevel * 1.25));

  Upgrade copyWith({
    int? currentLevel,
  }) {
    return Upgrade(
      id: id,
      title: title,
      description: description,
      type: type,
      currency: currency,
      baseCost: baseCost,
      costMultiplier: costMultiplier,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'currency': currency.name,
        'baseCost': baseCost,
        'costMultiplier': costMultiplier,
        'currentLevel': currentLevel,
        'maxLevel': maxLevel,
        'icon': icon,
      };

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: UpgradeType.values.firstWhere((t) => t.name == json['type']),
      currency: UpgradeCurrency.values.firstWhere((c) => c.name == json['currency']),
      baseCost: (json['baseCost'] as num).toDouble(),
      costMultiplier: (json['costMultiplier'] as num?)?.toDouble() ?? 1.6,
      currentLevel: json['currentLevel'] as int? ?? 0,
      maxLevel: json['maxLevel'] as int? ?? 10,
      icon: json['icon'] as String? ?? '⭐',
    );
  }
}
