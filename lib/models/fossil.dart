enum FossilRarity { common, uncommon, rare, legendary }

class FossilItem {
  final String id;
  final String name;
  final String description;
  final FossilRarity rarity;
  final String iconEmoji;
  final double dnaBonus;
  final double researchBonus;
  final int count;

  const FossilItem({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.iconEmoji,
    required this.dnaBonus,
    required this.researchBonus,
    this.count = 1,
  });

  FossilItem copyWith({int? count}) {
    return FossilItem(
      id: id,
      name: name,
      description: description,
      rarity: rarity,
      iconEmoji: iconEmoji,
      dnaBonus: dnaBonus,
      researchBonus: researchBonus,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'rarity': rarity.name,
    'iconEmoji': iconEmoji,
    'dnaBonus': dnaBonus,
    'researchBonus': researchBonus,
    'count': count,
  };

  factory FossilItem.fromJson(Map<String, dynamic> json) {
    return FossilItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: FossilRarity.values.firstWhere(
        (r) => r.name == json['rarity'],
        orElse: () => FossilRarity.common,
      ),
      iconEmoji: json['iconEmoji'] as String? ?? '🦴',
      dnaBonus: (json['dnaBonus'] as num?)?.toDouble() ?? 0.0,
      researchBonus: (json['researchBonus'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 1,
    );
  }
}
