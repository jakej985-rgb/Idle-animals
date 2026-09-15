import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/upgrade.dart';

class UpgradesSheet extends StatelessWidget {
  final GameState state;
  final Function(String) onBuyUpgrade;

  const UpgradesSheet({
    super.key,
    required this.state,
    required this.onBuyUpgrade,
  });

  @override
  Widget build(BuildContext context) {
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
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'Sanctuary Upgrades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '🪙 ${state.credits.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: state.upgrades.values.map((upg) {
                return _buildUpgradeCard(context, upg);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, Upgrade upg) {
    final cost = upg.currentCost;
    bool canAfford = false;
    String currencyIcon = '🪙';
    Color currencyColor = const Color(0xFFFBBF24);

    switch (upg.currency) {
      case UpgradeCurrency.credits:
        canAfford = state.credits >= cost;
        currencyIcon = '🪙';
        currencyColor = const Color(0xFFFBBF24);
        break;
      case UpgradeCurrency.dna:
        canAfford = state.dna >= cost;
        currencyIcon = '🧬';
        currencyColor = const Color(0xFF38BDF8);
        break;
      case UpgradeCurrency.research:
        canAfford = state.research >= cost;
        currencyIcon = '🔬';
        currencyColor = const Color(0xFFA78BFA);
        break;
    }

    final isMaxed = upg.isMaxed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaxed
              ? const Color(0xFF10B981).withOpacity(0.4)
              : const Color(0xFF1E3142),
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
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? const Color(0xFF10B981).withOpacity(0.2)
                            : const Color(0xFF1B3147),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isMaxed ? 'MAX' : 'Lv ${upg.currentLevel}',
                        style: TextStyle(
                          color: isMaxed
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF8BA3B8),
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
                    color: Color(0xFF8BA3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: (!isMaxed && canAfford)
                ? () => onBuyUpgrade(upg.id)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
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
