import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/research_node.dart';

class ResearchSheet extends StatelessWidget {
  final GameState state;
  final Function(String) onUnlockResearch;

  const ResearchSheet({
    super.key,
    required this.state,
    required this.onUnlockResearch,
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
              const Text('🔬', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'Genetic & Sanctuary Research',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '🔬 ${state.research.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Color(0xFFA78BFA),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: state.researchNodes.values.map((node) {
                return _buildResearchNodeCard(context, node);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchNodeCard(BuildContext context, ResearchNode node) {
    final isUnlocked = node.isUnlocked;

    // Check prerequisites
    bool prereqsMet = true;
    for (final prereqId in node.prerequisites) {
      final pNode = state.researchNodes[prereqId];
      if (pNode == null || !pNode.isUnlocked) {
        prereqsMet = false;
        break;
      }
    }

    final canAfford = state.research >= node.cost && prereqsMet && !isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C141D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF10B981).withOpacity(0.5)
              : (prereqsMet ? const Color(0xFF8B5CF6).withOpacity(0.4) : const Color(0xFF1E3142)),
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
                  : (prereqsMet ? const Color(0xFF2E1065) : const Color(0xFF1E293B)),
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RESEARCHED',
                          style: TextStyle(
                            color: Color(0xFF4ADE80),
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
                    color: Color(0xFF8BA3B8),
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
              onPressed: canAfford ? () => onUnlockResearch(node.id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF1E293B),
                disabledForegroundColor: Colors.white24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
