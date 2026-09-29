import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/mission.dart';
import '../providers/game_notifier.dart';

class MissionsSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onClaimMission;

  const MissionsSheet({
    super.key,
    this.state,
    this.onClaimMission,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
    final missions = activeState.missions.values.toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131D2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF284860),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Text('🎯', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Conservation Directives',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete guided objectives to unlock grant bonuses and accelerate ancient species recovery.',
            style: TextStyle(color: Color(0xFF8BA3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: missions.map((m) {
                return _buildMissionCard(context, m, controller);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
      BuildContext context, Mission m, GameNotifier controller) {
    final isDone = m.isCompleted;
    final isClaimed = m.isClaimed;
    final progressVal =
        (m.currentProgress / m.targetCount).clamp(0.0, 1.0);

    String rewardIcon = '🪙';
    Color rewardColor = const Color(0xFFFBBF24);
    switch (m.rewardType) {
      case MissionRewardType.credits:
        rewardIcon = '🪙';
        rewardColor = const Color(0xFFFBBF24);
        break;
      case MissionRewardType.dna:
        rewardIcon = '🧬';
        rewardColor = const Color(0xFF38BDF8);
        break;
      case MissionRewardType.research:
        rewardIcon = '🔬';
        rewardColor = const Color(0xFFA78BFA);
        break;
      case MissionRewardType.restorationPoints:
        rewardIcon = '⭐';
        rewardColor = const Color(0xFF4ADE80);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClaimed
              ? const Color(0xFF1E293B)
              : (isDone ? const Color(0xFF10B981) : const Color(0xFF1E3142)),
          width: isDone && !isClaimed ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isClaimed ? const Color(0xFF121B24) : const Color(0xFF1B2B3A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(m.iconEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: TextStyle(
                    color: isClaimed ? Colors.white38 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.description,
                  style: TextStyle(
                    color: isClaimed ? Colors.white24 : const Color(0xFF8BA3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF182635),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.currentProgress} / ${m.targetCount}',
                  style: TextStyle(
                    color: isClaimed ? Colors.white24 : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isClaimed)
            const Text('Claimed ✓',
                style: TextStyle(color: Colors.white38, fontSize: 11))
          else if (isDone)
            ElevatedButton(
              onPressed: () {
                if (onClaimMission != null) {
                  onClaimMission!(m.id);
                } else {
                  controller.claimMissionReward(m.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rewardIcon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '+${m.rewardAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF162534),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rewardIcon, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    '+${m.rewardAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: rewardColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
