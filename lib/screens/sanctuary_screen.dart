import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';
import '../widgets/currency_header.dart';
import '../widgets/habitat_viewport.dart';
import '../widgets/needs_panel.dart';
import '../widgets/offline_modal.dart';
import '../widgets/restoration_modal.dart';
import 'archive_sheet.dart';
import 'expeditions_sheet.dart';
import 'missions_sheet.dart';
import 'research_sheet.dart';
import 'staff_sheet.dart';
import 'upgrades_sheet.dart';
import 'world_map_sheet.dart';

class SanctuaryScreen extends ConsumerStatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  ConsumerState<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends ConsumerState<SanctuaryScreen> {
  bool _offlineModalShown = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    // Show offline progress modal if pending
    if (!_offlineModalShown && controller.pendingOfflineReport != null) {
      _offlineModalShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => OfflineModal(
            report: controller.pendingOfflineReport!,
            onCollect: () {
              controller.dismissOfflineReport();
              Navigator.of(ctx).pop();
            },
          ),
        );
      });
    }

    final habitat =
        state.habitats[state.activeHabitatId] ?? state.habitats.values.first;

    // Check badges for notifications
    final hasCompletedExpedition =
        state.expeditions.values.any((e) => e.isCompleted);
    final hasClaimableMission =
        state.missions.values.any((m) => m.isCompleted && !m.isClaimed);

    return Scaffold(
      backgroundColor: const Color(0xFF070E17),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 1. Top Header: Currencies & Live Rates
                    CurrencyHeader(state: state),
                    const SizedBox(height: 8),

                    // 2. Quick Action Bar (Map Switcher, Expeditions, Missions, Prestige, Audio)
                    _buildTopActionBar(context, state, controller,
                        hasCompletedExpedition, hasClaimableMission),
                    const SizedBox(height: 8),

                    // 3. Habitat Title & Status Badge
                    Row(
                      children: [
                        Text(_getBiomeEmoji(habitat.biomeType),
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habitat.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    const Color(0xFF38BDF8).withOpacity(0.4)),
                          ),
                          child: Text(
                            'Reserve Lv ${habitat.level}',
                            style: const TextStyle(
                              color: Color(0xFF7DD3FC),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 4. Living Multi-Biome Habitat Viewport
                    Expanded(
                      flex: 5,
                      child: HabitatViewport(
                        habitat: habitat,
                        onTap: () => controller.petAnimals(habitat.id),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 5. Animal Needs & Breeding Panel
                    NeedsPanel(
                      habitat: habitat,
                      credits: state.credits,
                      dna: state.dna,
                      onFeed: () => controller.feedHabitat(habitat.id),
                      onWater: () => controller.waterHabitat(habitat.id),
                      onRevive: () => controller.reviveSpecies(habitat.id),
                    ),
                    const SizedBox(height: 10),

                    // 6. Navigation Action Dock
                    _buildDock(context, state, controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopActionBar(
    BuildContext context,
    GameState state,
    GameNotifier controller,
    bool hasExpeditionBadge,
    bool hasMissionBadge,
  ) {
    return Row(
      children: [
        // World Map Button
        InkWell(
          onTap: () => _openSheet(
            context,
            WorldMapSheet(
              state: state,
              onSelectHabitat: (id) => controller.switchActiveHabitat(id),
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF162534),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF233B50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌎', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  'Map (${state.habitats.length})',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Expeditions Button
        InkWell(
          onTap: () => _openSheet(
            context,
            ExpeditionsSheet(
              state: state,
              onStartExpedition: (id) => controller.startExpedition(id),
              onClaimExpedition: (id) => controller.claimExpedition(id),
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF162534),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF233B50)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🧭', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Expeditions',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasExpeditionBadge)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Missions Button
        InkWell(
          onTap: () => _openSheet(
            context,
            MissionsSheet(
              state: state,
              onClaimMission: (id) => controller.claimMissionReward(id),
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF162534),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF233B50)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Directives',
                      style: TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasMissionBadge)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),

        // Ecosystem Restoration (Prestige) Button
        InkWell(
          onTap: () {
            final activeHab =
                state.habitats[state.activeHabitatId] ?? state.habitats.values.first;
            showDialog(
              context: context,
              builder: (ctx) => RestorationModal(
                state: state,
                habitat: activeHab,
                onConfirmRestore: () {
                  controller.restoreEcosystem(activeHab.id);
                  Navigator.of(ctx).pop();
                },
                onBuyPerk: (key) => controller.buyRestorationPerk(key),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF047857).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌿', style: TextStyle(fontSize: 13)),
                SizedBox(width: 3),
                Text(
                  'Restore',
                  style: TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Sound Toggle Button
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: Icon(
            state.soundEnabled ? Icons.volume_up : Icons.volume_off,
            color: state.soundEnabled ? Colors.white70 : Colors.white24,
            size: 18,
          ),
          onPressed: () => controller.toggleSound(),
        ),
      ],
    );
  }

  Widget _buildDock(
    BuildContext context,
    GameState state,
    GameNotifier controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3142)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockButton(
            icon: '🏝️',
            label: 'Sanctuary',
            isSelected: true,
            onTap: () {},
          ),
          _buildDockButton(
            icon: '⭐',
            label: 'Upgrades',
            onTap: () => _openSheet(
              context,
              UpgradesSheet(
                state: state,
                onBuyUpgrade: (id) => controller.buyUpgrade(id),
              ),
            ),
          ),
          _buildDockButton(
            icon: '🧑‍🌾',
            label: 'Staff',
            onTap: () => _openSheet(
              context,
              StaffSheet(
                state: state,
                onHireOrUpgrade: (id) => controller.hireOrUpgradeStaff(id),
              ),
            ),
          ),
          _buildDockButton(
            icon: '🔬',
            label: 'Research',
            onTap: () => _openSheet(
              context,
              ResearchSheet(
                state: state,
                onUnlockResearch: (id) => controller.unlockResearch(id),
              ),
            ),
          ),
          _buildDockButton(
            icon: '📜',
            label: 'Archive',
            onTap: () => _openSheet(
              context,
              ArchiveSheet(state: state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton({
    required String icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3147) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF38BDF8) : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBiomeEmoji(String biome) {
    switch (biome) {
      case 'australian_forest':
        return '🌲';
      case 'northern_coast':
        return '🌊';
      case 'african_grasslands':
        return '🌾';
      case 'ice_age_tundra':
        return '❄️';
      default:
        return '🌴';
    }
  }

  void _openSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.78,
        child: sheet,
      ),
    );
  }
}
