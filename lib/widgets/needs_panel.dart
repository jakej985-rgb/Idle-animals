import 'package:flutter/material.dart';
import '../models/habitat.dart';

class NeedsPanel extends StatelessWidget {
  final Habitat habitat;
  final double credits;
  final double dna;
  final VoidCallback onFeed;
  final VoidCallback onWater;
  final VoidCallback onRevive;

  const NeedsPanel({
    super.key,
    required this.habitat,
    required this.credits,
    required this.dna,
    required this.onFeed,
    required this.onWater,
    required this.onRevive,
  });

  String _getHappinessText(double happiness) {
    if (happiness >= 85) return 'Thriving 🥰 (+20% Output)';
    if (happiness >= 60) return 'Content 😊 (Normal)';
    if (happiness >= 40) return 'Needs Attention 😐 (-25%)';
    return 'Unhappy 🥺 (Low Output)';
  }

  Color _getHappinessColor(double happiness) {
    if (happiness >= 85) return const Color(0xFF4ADE80);
    if (happiness >= 60) return const Color(0xFF38BDF8);
    if (happiness >= 40) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    final bool canRevive = dna >= 15.0 && habitat.population < habitat.capacity;
    final bool isAtCapacity = habitat.population >= habitat.capacity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101A24).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3142)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Population & Breeding Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3147),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🦤', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dodo Population',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${habitat.population} / ${habitat.capacity}',
                          style: TextStyle(
                            color: isAtCapacity
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFF4ADE80),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Breeding Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: isAtCapacity ? 1.0 : habitat.breedingProgress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF1B2B3A),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAtCapacity
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAtCapacity
                          ? 'Capacity reached. Expand island in Upgrades!'
                          : 'Next Dodo breeding: ${(habitat.breedingProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isAtCapacity
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF8BA3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Revive Species Button
              ElevatedButton(
                onPressed: canRevive ? onRevive : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF0284C7).withOpacity(0.2),
                  disabledForegroundColor: Colors.white30,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🧬 Revive',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('15 DNA',
                        style: TextStyle(
                            fontSize: 9, color: Color(0xFFBAE6FD))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFF1E3142), height: 1),
          const SizedBox(height: 14),

          // Needs Bars (Food, Water, Happiness)
          Row(
            children: [
              // Food
              Expanded(
                child: _buildNeedBar(
                  icon: '🍎',
                  label: 'Food',
                  percent: habitat.foodPercentage,
                  color: const Color(0xFFF97316),
                  isAuto: habitat.hasAutoFeeder,
                  onAction: onFeed,
                  actionLabel: 'Feed (5🪙)',
                  enabled: credits >= 5 || credits == 0,
                ),
              ),
              const SizedBox(width: 12),
              // Water
              Expanded(
                child: _buildNeedBar(
                  icon: '💧',
                  label: 'Water',
                  percent: habitat.waterPercentage,
                  color: const Color(0xFF38BDF8),
                  isAuto: habitat.hasAutoWater,
                  onAction: onWater,
                  actionLabel: 'Pump Pool',
                  enabled: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Happiness Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C141D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getHappinessColor(habitat.happiness).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Welfare: ${habitat.happiness.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getHappinessColor(habitat.happiness),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _getHappinessText(habitat.happiness),
                  style: TextStyle(
                    color: _getHappinessColor(habitat.happiness),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedBar({
    required String icon,
    required String label,
    required double percent,
    required Color color,
    required bool isAuto,
    required VoidCallback onAction,
    required String actionLabel,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3142)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isAuto)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AUTO',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: const Color(0xFF1B2B3A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: isAuto ? null : (enabled ? onAction : null),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAuto ? Colors.white12 : color.withOpacity(0.6),
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isAuto ? 'Automated' : actionLabel,
                style: TextStyle(
                  color: isAuto ? Colors.white38 : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
