import 'package:extinction_sanctuary/core/ui/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/species.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class WorldMapSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onSelectHabitat;

  const WorldMapSheet({
    super.key,
    this.state,
    this.onSelectHabitat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
    // Define the full canonical list of regional sanctuaries
    final regions = [
      {
        'habitatId': 'dodo_island',
        'speciesId': 'dodo',
        'name': 'Dodo Island Sanctuary',
        'region': 'Indian Ocean / Mauritius',
        'icon': '🌴',
      },
      {
        'habitatId': 'tasman_forest',
        'speciesId': 'thylacine',
        'name': 'Tasmanian Forest Reserve',
        'region': 'Australian Forest',
        'icon': '🌲',
      },
      {
        'habitatId': 'north_coast',
        'speciesId': 'great_auk',
        'name': 'Northern Skerries Reserve',
        'region': 'North Atlantic Coast',
        'icon': '🌊',
      },
      {
        'habitatId': 'karoo_reserve',
        'speciesId': 'quagga',
        'name': 'Karoo Plains Reserve',
        'region': 'African Grasslands',
        'icon': '🌾',
      },
      {
        'habitatId': 'siberia_tundra',
        'speciesId': 'woolly_mammoth',
        'name': 'Ice Age Glacial Reserve',
        'region': 'Siberian Permafrost',
        'icon': '❄️',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            icon: '🌎',
            title: 'Global Sanctuary Network',
            subtitle:
                'Switch between restored sanctuaries. Each habitat operates concurrently.',
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: regions.map((r) {
                final habitatId = r['habitatId'] as String;
                final speciesId = r['speciesId'] as String;
                final species = Species.fromId(speciesId);
                final habitat = activeState.habitats[habitatId];
                final isUnlocked = habitat != null;
                final isActive = activeState.activeHabitatId == habitatId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1B3852)
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? AppColors.accent
                          : (isUnlocked
                              ? AppColors.border
                              : const Color(0xFF162330)),
                      width: isActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF13202E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUnlocked
                                ? AppColors.accent.withValues(alpha: 0.3)
                                : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isUnlocked ? species.iconEmoji : '🔒',
                            style: const TextStyle(fontSize: 24),
                          ),
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
                                    r['name'] as String,
                                    style: TextStyle(
                                      color: isUnlocked
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: AppColors.onFill(
                                            AppColors.primary),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              r['region'] as String,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            if (isUnlocked) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${habitat.population} ${species.name}s • Lv ${habitat.level} Reserve',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Discover species fossils on expedition to unlock',
                                style: TextStyle(
                                  color: AppColors.amber,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isUnlocked && !isActive)
                        ElevatedButton(
                          onPressed: () {
                            if (onSelectHabitat != null) {
                              onSelectHabitat!(habitatId);
                            } else {
                              controller.switchActiveHabitat(habitatId);
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor:
                                AppColors.onFill(AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('View',
                              style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
