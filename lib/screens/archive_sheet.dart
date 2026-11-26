import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/species.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class ArchiveSheet extends ConsumerWidget {
  final GameState? state;

  const ArchiveSheet({
    super.key,
    this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final allSpecies = Species.registry.values.toList();

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
            icon: '📜',
            title: 'Extinction Archive',
            subtitle:
                'Species restored: ${activeState.unlockedSpeciesIds.length} / ${allSpecies.length}',
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: allSpecies.map((species) {
                final isUnlocked =
                    activeState.unlockedSpeciesIds.contains(species.id);

                if (isUnlocked) {
                  return _buildUnlockedCard(species, activeState);
                } else {
                  return _buildLockedCard(species);
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedCard(Species species, GameState activeState) {
    int currentPop = 0;
    for (final hab in activeState.habitats.values) {
      if (hab.speciesId == species.id) {
        currentPop += hab.population;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B3147),
            Color(0xFF101D2C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.emerald, width: 1.5),
                ),
                child: Center(
                  child: Text(species.iconEmoji,
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
                        Flexible(
                          child: Text(
                            species.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'RESTORED',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      species.scientificName,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Extinction: ${species.extinctionEra}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            species.description,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B141E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  label: 'Sanctuary Population',
                  value: '$currentPop ${species.iconEmoji}',
                  color: AppColors.success,
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                _buildMiniStat(
                  label: 'Base Breeding Cycle',
                  value: '${species.baseBreedingSeconds.toStringAsFixed(0)}s',
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCard(Species species) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.6),
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
                opacity: 0.35,
                child: Text(species.iconEmoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species.name,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${species.extinctionEra} • ${species.scientificName}',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Discover fossil DNA fragments on expeditions to restore',
                  style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Text('🔒', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
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
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
