import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format/game_format.dart';
import '../models/game_state.dart';
import '../models/research_node.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class ResearchSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onUnlockResearch;

  const ResearchSheet({super.key, this.state, this.onUnlockResearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
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
            icon: '🔬',
            title: 'Genetic & Sanctuary Research',
            subtitle: 'Unlock permanent genetic and operational boosts',
            trailing: Text(
              '🔬 ${GameFormat.decimal(activeState.research)}',
              style: const TextStyle(
                color: AppColors.purple,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFeatures: AppText.tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: activeState.researchNodes.values.map((node) {
                return _buildResearchNodeCard(
                  context,
                  node,
                  activeState,
                  controller,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchNodeCard(
    BuildContext context,
    ResearchNode node,
    GameState activeState,
    GameNotifier controller,
  ) {
    final isUnlocked = node.isUnlocked;

    // Check prerequisites
    bool prereqsMet = true;
    for (final prereqId in node.prerequisites) {
      final pNode = activeState.researchNodes[prereqId];
      if (pNode == null || !pNode.isUnlocked) {
        prereqsMet = false;
        break;
      }
    }

    final canAfford =
        activeState.research >= node.cost && prereqsMet && !isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isUnlocked
              ? AppColors.emerald.withValues(alpha: 0.5)
              : (prereqsMet
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                    : AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFF064E3B)
                  : (prereqsMet
                        ? const Color(0xFF2E1065)
                        : const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(node.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        node.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RESEARCHED',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  node.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                if (!prereqsMet) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Requires preceding research in genetics tree',
                    style: TextStyle(
                      color: Colors.amber.shade300,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isUnlocked)
            ElevatedButton(
              onPressed: canAfford
                  ? () {
                      if (onUnlockResearch != null) {
                        onUnlockResearch!(node.id);
                      } else {
                        controller.unlockResearch(node.id);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: AppColors.onFill(const Color(0xFF7C3AED)),
                disabledBackgroundColor: const Color(0xFF1E293B),
                disabledForegroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔬', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    node.cost.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.white : Colors.white24,
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
