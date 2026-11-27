enum StaffRole { keeper, veterinarian, geneticist, botanist, researcher }

class StaffMember {
  final String id;
  final String name;
  final StaffRole role;
  final int level;
  final String title;
  final String description;
  final String avatarEmoji;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.level = 0,
    required this.title,
    required this.description,
    required this.avatarEmoji,
  });

  bool get isHired => level > 0;

  // Base hire cost: 100 credits; level up cost scales with level
  double get upgradeCost => isHired ? (100.0 * (1.8 * level)) : 100.0;

  // Keeper bonuses: +15% happiness retention and +10% breeding speed per level
  double get happinessBonusPerLevel => 0.05;
  double get growthBonusMultiplier => 1.0 + (level * 0.10);

  StaffMember copyWith({
    String? id,
    String? name,
    StaffRole? role,
    int? level,
    String? title,
    String? description,
    String? avatarEmoji,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'level': level,
    'title': title,
    'description': description,
    'avatarEmoji': avatarEmoji,
  };

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String,
      role: StaffRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => StaffRole.keeper,
      ),
      level: json['level'] as int? ?? 0,
      title: json['title'] as String,
      description: json['description'] as String,
      avatarEmoji: json['avatarEmoji'] as String? ?? '🧑‍🌾',
    );
  }
}
