class ResearchNode {
  final String id;
  final String title;
  final String description;
  final double cost; // in Research points
  final bool isUnlocked;
  final List<String> prerequisites;
  final String icon;

  const ResearchNode({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    this.isUnlocked = false,
    this.prerequisites = const [],
    required this.icon,
  });

  ResearchNode copyWith({
    bool? isUnlocked,
  }) {
    return ResearchNode(
      id: id,
      title: title,
      description: description,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      prerequisites: prerequisites,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cost': cost,
        'isUnlocked': isUnlocked,
        'prerequisites': prerequisites,
        'icon': icon,
      };

  factory ResearchNode.fromJson(Map<String, dynamic> json) {
    return ResearchNode(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      icon: json['icon'] as String? ?? '🧬',
    );
  }
}
