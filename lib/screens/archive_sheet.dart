import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/species.dart';

class ArchiveSheet extends StatelessWidget {
  final GameState state;

  const ArchiveSheet({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final dodo = Species.dodo;
    final habitat = state.habitats['dodo_island'];
    final currentPop = habitat?.population ?? 0;

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
            children: const [
              Text('📜', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Extinction Archive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // Unlocked Dodo Card
                Container(
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
                      color: const Color(0xFF10B981).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1E2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Center(
                              child: Text(dodo.iconEmoji,
                                  style: const TextStyle(fontSize: 32)),
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
                                      dodo.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'RESTORED',
                                        style: TextStyle(
                                          color: Color(0xFF4ADE80),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dodo.scientificName,
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Extinction: ${dodo.extinctionEra}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dodo.description,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B141E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat(
                              label: 'Current Population',
                              value: '$currentPop 🦤',
                              color: const Color(0xFF4ADE80),
                            ),
                            Container(
                                width: 1,
                                height: 24,
                                color: const Color(0xFF1E3142)),
                            _buildMiniStat(
                              label: 'Total Bred in Reserve',
                              value: '${state.totalDodosBred}',
                              color: const Color(0xFF38BDF8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Locked teaser cards
                _buildLockedSpeciesCard(
                  emoji: '🐺',
                  name: 'Thylacine (Tasmanian Tiger)',
                  era: 'c. 1936 (Tasmania)',
                  habitat: 'Australian Forest',
                ),
                const SizedBox(height: 10),
                _buildLockedSpeciesCard(
                  emoji: '🐧',
                  name: 'Great Auk',
                  era: 'c. 1852 (North Atlantic)',
                  habitat: 'Northern Coast',
                ),
                const SizedBox(height: 10),
                _buildLockedSpeciesCard(
                  emoji: '🦣',
                  name: 'Woolly Mammoth',
                  era: 'c. 4000 BP (Wrangel Island)',
                  habitat: 'Ice Age Tundra',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8BA3B8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedSpeciesCard({
    required String emoji,
    required String name,
    required String era,
    required String habitat,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF182534)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF141F2B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$era • $habitat',
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
