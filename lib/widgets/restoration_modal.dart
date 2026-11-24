import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/habitat.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';

class RestorationModal extends ConsumerWidget {
  final GameState? state;
  final Habitat? habitat;
  final VoidCallback? onConfirmRestore;
  final Function(String)? onBuyPerk;

  const RestorationModal({
    super.key,
    this.state,
    this.habitat,
    this.onConfirmRestore,
    this.onBuyPerk,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
    final activeHabitat = habitat ??
        activeState.habitats[activeState.activeHabitatId] ??
        activeState.habitats.values.first;
    final earnedPoints = activeHabitat.calculateRestorationPoints();
    final canRestore = activeHabitat.population >= 10 || activeHabitat.level >= 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF131D2A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'RESTORE ${activeHabitat.name.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Complete the ecological restoration of this region. The reserve resets to Level 1, awarding permanent Restoration Points for global sanctuary upgrades.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8BA3B8), fontSize: 11),
              ),
              const SizedBox(height: 14),

              // Current Status Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C141D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E3142)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Population', '${activeHabitat.population}', const Color(0xFF4ADE80)),
                    Container(width: 1, height: 28, color: const Color(0xFF1E3142)),
                    _buildStatCol('Reserve Level', 'Lv ${activeHabitat.level}', const Color(0xFF38BDF8)),
                    Container(width: 1, height: 28, color: const Color(0xFF1E3142)),
                    _buildStatCol('Reward', '+$earnedPoints ⭐', const Color(0xFFFBBF24)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Restore Button
              ElevatedButton(
                onPressed: canRestore
                    ? () {
                        if (onConfirmRestore != null) {
                          onConfirmRestore!();
                        } else {
                          controller.restoreEcosystem(activeHabitat.id);
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: AppColors.onFill(const Color(0xFF10B981)),
                  disabledBackgroundColor: const Color(0xFF162534),
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canRestore
                      ? 'RESTORE ECOSYSTEM (+$earnedPoints ⭐)'
                      : 'Reach Pop 10 or Reserve Lv 2 to Restore',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 18),

              // Permanent Restoration Perks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Permanent Global Perks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available: ${activeState.restorationPoints.toStringAsFixed(0)} ⭐',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildPerkRow(
                activeState: activeState,
                controller: controller,
                icon: '👶',
                title: 'Species Growth Boost',
                desc: '+15% breeding speed across all reserves',
                perkKey: 'growth_boost',
              ),
              _buildPerkRow(
                activeState: activeState,
                controller: controller,
                icon: '🧬',
                title: 'Ancient DNA Synthesis',
                desc: '+20% DNA harvested from all animals',
                perkKey: 'dna_boost',
              ),
              _buildPerkRow(
                activeState: activeState,
                controller: controller,
                icon: '🔬',
                title: 'Conservation Research Lab',
                desc: '+20% research production across all reserves',
                perkKey: 'research_boost',
              ),
              _buildPerkRow(
                activeState: activeState,
                controller: controller,
                icon: '🧭',
                title: 'Field Radar Vehicles',
                desc: '+25% faster expedition travel times',
                perkKey: 'expedition_boost',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8BA3B8), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow({
    required GameState activeState,
    required GameNotifier controller,
    required String icon,
    required String title,
    required String desc,
    required String perkKey,
  }) {
    final lvl = activeState.restorationPerks[perkKey] ?? 0;
    final cost = (lvl + 1) * 5;
    final canAfford = activeState.restorationPoints >= cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3142)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lv $lvl',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    if (onBuyPerk != null) {
                      onBuyPerk!(perkKey);
                    } else {
                      controller.buyRestorationPerk(perkKey);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: AppColors.onFill(const Color(0xFF0284C7)),
              disabledBackgroundColor: const Color(0xFF162534),
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '$cost ⭐',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
