import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/mission.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

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
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            icon: '🎯',
            title: 'Conservation Directives',
            subtitle:
                'Complete guided objectives to unlock grants and accelerate species recovery.',
          ),
          const SizedBox(height: 14),
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
    Color rewardColor = AppColors.amber;
    switch (m.rewardType) {
      case MissionRewardType.credits:
        rewardIcon = '🪙';
        rewardColor = AppColors.amber;
        break;
      case MissionRewardType.dna:
        rewardIcon = '🧬';
        rewardColor = AppColors.accent;
        break;
      case MissionRewardType.research:
        rewardIcon = '🔬';
        rewardColor = AppColors.purple;
        break;
      case MissionRewardType.restorationPoints:
        rewardIcon = '⭐';
        rewardColor = AppColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClaimed
              ? const Color(0xFF1E293B)
              : (isDone ? AppColors.emerald : AppColors.border),
          width: isDone && !isClaimed ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isClaimed ? const Color(0xFF121B24) : AppColors.track,
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
                    color: isClaimed ? Colors.white24 : AppColors.textMuted,
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
                      isDone ? AppColors.emerald : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.currentProgress} / ${m.targetCount}',
                  style: TextStyle(
                    color: isClaimed ? Colors.white24 : AppColors.textSubdued,
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
                backgroundColor: AppColors.emerald,
                foregroundColor: AppColors.onFill(AppColors.emerald),
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
