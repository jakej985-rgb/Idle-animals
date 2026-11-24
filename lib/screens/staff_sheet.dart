import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/format/game_format.dart';
import '../models/game_state.dart';
import '../models/staff.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class StaffSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onHireOrUpgrade;

  const StaffSheet({
    super.key,
    this.state,
    this.onHireOrUpgrade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
    final keeper = activeState.staff['keeper'];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            icon: '🧑‍🌾',
            title: 'Sanctuary Staff',
            subtitle: 'Keepers automate care and accelerate growth',
            trailing: Text(
              '🪙 ${GameFormat.compact(activeState.credits)}',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFeatures: AppText.tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (keeper != null)
                    _buildKeeperCard(
                      context,
                      keeper,
                      activeState,
                      controller,
                    ),
                  const SizedBox(height: 14),
                  // Preview of upcoming staff roles
                  _buildUpcomingRole(
                    avatar: '🩺',
                    title: 'Dr. Evelyn, Veterinarian',
                    desc:
                        'Unlocks in next region. Monitors welfare & disease prevention.',
                  ),
                  const SizedBox(height: 10),
                  _buildUpcomingRole(
                    avatar: '🧬',
                    title: 'Dr. Aris, Geneticist',
                    desc:
                        'Unlocks with ancient fossils. Accelerates DNA synthesis.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeeperCard(BuildContext context, StaffMember keeper,
      GameState activeState, GameNotifier controller) {
    final cost = keeper.upgradeCost;
    final canAfford = activeState.credits >= cost;
    final isHired = keeper.isHired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B3147),
            const Color(0xFF101D2C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHired
              ? AppColors.accent.withOpacity(0.5)
              : const Color(0xFF223A50),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E2E),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: Center(
                  child: Text(keeper.avatarEmoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            keeper.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isHired
                                ? AppColors.emerald.withOpacity(0.2)
                                : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHired ? 'Level ${keeper.level}' : 'Not Hired',
                            style: TextStyle(
                              color: isHired
                                  ? AppColors.success
                                  : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      keeper.title,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            keeper.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B141E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Current Growth Bonus',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '+${(keeper.level * 15)}% Speed & Auto-Feed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    if (onHireOrUpgrade != null) {
                      onHireOrUpgrade!(keeper.id);
                    } else {
                      controller.hireOrUpgradeStaff(keeper.id);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: AppColors.onFill(AppColors.emerald),
              disabledBackgroundColor: AppColors.track,
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isHired
                  ? 'Upgrade Keeper (🪙 ${cost.toStringAsFixed(0)})'
                  : 'Hire Keeper (🪙 ${cost.toStringAsFixed(0)})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRole({
    required String avatar,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF182534)),
      ),
      child: Row(
        children: [
          Text(avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ],
            ),
          ),
          const Text('🔒', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
