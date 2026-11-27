import 'package:material_ui/material_ui.dart';

import '../core/format/game_format.dart';
import '../core/simulation/simulation_engine.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class CurrencyHeader extends StatelessWidget {
  final GameState state;

  const CurrencyHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final rates = SimulationEngine.totalRates(state);
    final credsRate = rates.creditsPerSec;
    final dnaRate = rates.dnaPerSec;
    final resRate = rates.researchPerSec;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCurrencyItem(
            icon: '🪙',
            label: 'Credits',
            amount: GameFormat.compact(state.credits),
            rate: GameFormat.rate(credsRate),
            color: AppColors.amber,
          ),
          const _Divider(),
          _buildCurrencyItem(
            icon: '🧬',
            label: 'DNA',
            amount: GameFormat.compact(state.dna),
            rate: GameFormat.rate(dnaRate),
            color: AppColors.accent,
          ),
          const _Divider(),
          _buildCurrencyItem(
            icon: '🔬',
            label: 'Research',
            amount: GameFormat.compact(state.research),
            rate: GameFormat.rate(resRate),
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required String icon,
    required String label,
    required String amount,
    required String rate,
    required Color color,
  }) {
    return Expanded(
      child: Semantics(
        container: true,
        label: '$label: $amount. Generating $rate',
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      amount,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFeatures: AppText.tabularFigures,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                rate,
                maxLines: 1,
                style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppText.tabularFigures,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.border,
    );
  }
}
