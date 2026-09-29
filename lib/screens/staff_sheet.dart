import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/staff.dart';
import '../providers/game_notifier.dart';

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
            children: [
              const Text('🧑‍🌾', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'Sanctuary Staff',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '🪙 ${activeState.credits.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (keeper != null)
            _buildKeeperCard(context, keeper, activeState, controller),
          const SizedBox(height: 14),
          // Preview of upcoming staff roles
          _buildUpcomingRole(
            avatar: '🩺',
            title: 'Dr. Evelyn, Veterinarian',
            desc: 'Unlocks in next region. Monitors welfare & disease prevention.',
          ),
          const SizedBox(height: 10),
          _buildUpcomingRole(
            avatar: '🧬',
            title: 'Dr. Aris, Geneticist',
            desc: 'Unlocks with ancient fossils. Accelerates DNA synthesis.',
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
              ? const Color(0xFF38BDF8).withOpacity(0.5)
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
                  border: Border.all(color: const Color(0xFF38BDF8), width: 2),
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
                        Text(
                          keeper.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isHired
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHired ? 'Level ${keeper.level}' : 'Not Hired',
                            style: TextStyle(
                              color: isHired
                                  ? const Color(0xFF4ADE80)
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
                        color: Color(0xFF38BDF8),
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
              color: Color(0xFF94A3B8),
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
                const Text(
                  'Current Growth Bonus',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                ),
                Text(
                  '+${(keeper.level * 15)}% Speed & Auto-Feed',
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF1B2B3A),
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
        color: const Color(0xFF0C141D).withOpacity(0.6),
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
