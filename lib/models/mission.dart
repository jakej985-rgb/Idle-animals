enum MissionRewardType { credits, dna, research, restorationPoints }

class Mission {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final MissionRewardType rewardType;
  final double rewardAmount;
  final String iconEmoji;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.rewardType,
    required this.rewardAmount,
    required this.iconEmoji,
  });

  Mission copyWith({int? currentProgress, bool? isCompleted, bool? isClaimed}) {
    return Mission(
      id: id,
      title: title,
      description: description,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      rewardType: rewardType,
      rewardAmount: rewardAmount,
      iconEmoji: iconEmoji,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetCount': targetCount,
    'currentProgress': currentProgress,
    'isCompleted': isCompleted,
    'isClaimed': isClaimed,
    'rewardType': rewardType.name,
    'rewardAmount': rewardAmount,
    'iconEmoji': iconEmoji,
  };

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetCount: json['targetCount'] as int,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
      rewardType: MissionRewardType.values.firstWhere(
        (r) => r.name == json['rewardType'],
        orElse: () => MissionRewardType.credits,
      ),
      rewardAmount: (json['rewardAmount'] as num).toDouble(),
      iconEmoji: json['iconEmoji'] as String? ?? '🎯',
    );
  }

  static List<Mission> defaultMissions() {
    return const [
      Mission(
        id: 'pop_5',
        title: 'Initial Colony',
        description: 'Raise your sanctuary dodo population to 5.',
        targetCount: 5,
        rewardType: MissionRewardType.credits,
        rewardAmount: 60.0,
        iconEmoji: '🦤',
      ),
      Mission(
        id: 'first_expedition',
        title: 'First Expedition',
        description: 'Dispatch an expedition to search for ancient fossils.',
        targetCount: 1,
        rewardType: MissionRewardType.dna,
        rewardAmount: 25.0,
        iconEmoji: '🗺️',
      ),
      Mission(
        id: 'keeper_upgrade',
        title: 'Dedicated Keeper',
        description: 'Hire and train Sarah the Keeper to Level 2.',
        targetCount: 2,
        rewardType: MissionRewardType.research,
        rewardAmount: 20.0,
        iconEmoji: '🧑‍🌾',
      ),
      Mission(
        id: 'unlock_thylacine',
        title: 'Marsupial Restoration',
        description: 'Revive and re-establish the Tasmanian Tiger (Thylacine).',
        targetCount: 1,
        rewardType: MissionRewardType.dna,
        rewardAmount: 50.0,
        iconEmoji: '🐺',
      ),
      Mission(
        id: 'pop_30',
        title: 'Thriving Ecosystem',
        description:
            'Achieve a total sanctuary population of 30 extinct animals.',
        targetCount: 30,
        rewardType: MissionRewardType.restorationPoints,
        rewardAmount: 15.0,
        iconEmoji: '⭐',
      ),
    ];
  }
}
