import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/species.dart';

class CurrencyHeader extends StatelessWidget {
  final GameState state;

  const CurrencyHeader({
    super.key,
    required this.state,
  });

  String _formatNumber(double val) {
    if (val >= 1000000000) {
      return '${(val / 1000000000).toStringAsFixed(2)}B';
    } else if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(2)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    } else {
      return val.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dnaUpgradeLevel = state.upgrades['dna_sequencer']?.currentLevel ?? 0;
    final ancientDna = state.researchNodes['ancient_dna']?.isUnlocked ?? false;
    final dnaMultiplier = (1.0 + (dnaUpgradeLevel * 0.20)) *
        (ancientDna ? 1.5 : 1.0) *
        state.globalDnaMultiplier;

    double credsRate = 0;
    double dnaRate = 0;
    double resRate = 0;

    for (final hab in state.habitats.values) {
      final species = Species.fromId(hab.speciesId);
      final happyMult = (hab.happiness / 100.0).clamp(0.2, 1.4);
      credsRate += hab.population * species.baseCreditsRatePerSec * happyMult;
      dnaRate += hab.population *
          species.baseDnaRatePerSec *
          happyMult *
          dnaMultiplier;
      resRate += hab.population *
          species.baseResearchRatePerSec *
          happyMult *
          state.globalResearchMultiplier;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101924).withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3142)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrencyItem(
            icon: '🪙',
            label: 'Credits',
            amount: _formatNumber(state.credits),
            rate: '+${credsRate.toStringAsFixed(1)}/s',
            color: const Color(0xFFFBBF24),
          ),
          Container(width: 1, height: 28, color: const Color(0xFF223A50)),
          _buildCurrencyItem(
            icon: '🧬',
            label: 'DNA',
            amount: _formatNumber(state.dna),
            rate: '+${dnaRate.toStringAsFixed(1)}/s',
            color: const Color(0xFF38BDF8),
          ),
          Container(width: 1, height: 28, color: const Color(0xFF223A50)),
          _buildCurrencyItem(
            icon: '🔬',
            label: 'Research',
            amount: _formatNumber(state.research),
            rate: '+${resRate.toStringAsFixed(1)}/s',
            color: const Color(0xFFA78BFA),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          rate,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
