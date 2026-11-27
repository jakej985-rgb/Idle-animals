import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format/game_format.dart';
import '../models/game_state.dart';
import '../models/upgrade.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class UpgradesSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onBuyUpgrade;

  const UpgradesSheet({super.key, this.state, this.onBuyUpgrade});

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
            icon: '⭐',
            title: 'Sanctuary Upgrades',
            subtitle: 'Permanent sanctuary-wide improvements',
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
            child: ListView(
              children: activeState.upgrades.values.map((upg) {
                return _buildUpgradeCard(context, upg, activeState, controller);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    Upgrade upg,
    GameState activeState,
    GameNotifier controller,
  ) {
    final cost = upg.currentCost;
    bool canAfford = false;
    String currencyIcon = '🪙';
    Color currencyColor = AppColors.amber;

    switch (upg.currency) {
      case UpgradeCurrency.credits:
        canAfford = activeState.credits >= cost;
        currencyIcon = '🪙';
        currencyColor = AppColors.amber;
        break;
      case UpgradeCurrency.dna:
        canAfford = activeState.dna >= cost;
        currencyIcon = '🧬';
        currencyColor = AppColors.accent;
        break;
      case UpgradeCurrency.research:
        canAfford = activeState.research >= cost;
        currencyIcon = '🔬';
        currencyColor = AppColors.purple;
        break;
    }

    final isMaxed = upg.isMaxed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isMaxed
              ? AppColors.emerald.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF162534),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(upg.icon, style: const TextStyle(fontSize: 24)),
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
                        upg.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? AppColors.emerald.withValues(alpha: 0.2)
                            : const Color(0xFF1B3147),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isMaxed ? 'MAX' : 'Lv ${upg.currentLevel}',
                        style: TextStyle(
                          color: isMaxed
                              ? AppColors.success
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  upg.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: (!isMaxed && canAfford)
                ? () {
                    if (onBuyUpgrade != null) {
                      onBuyUpgrade!(upg.id);
                    } else {
                      controller.buyUpgrade(upg.id);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onFill(AppColors.primary),
              disabledBackgroundColor: const Color(0xFF162534),
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isMaxed
                ? const Text('Done', style: TextStyle(fontSize: 12))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currencyIcon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        cost.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? currencyColor : Colors.white24,
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
