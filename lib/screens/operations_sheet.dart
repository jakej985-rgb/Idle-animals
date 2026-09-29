import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/species.dart';
import '../providers/game_notifier.dart';
import '../widgets/restoration_modal.dart';
import 'expeditions_sheet.dart';
import 'missions_sheet.dart';
import 'world_map_sheet.dart';

class OperationsSheet extends ConsumerWidget {
  final GameState? state;
  final GameNotifier? controller;
  final void Function(Widget sheet)? onOpenSubSheet;

  const OperationsSheet({
    super.key,
    this.state,
    this.controller,
    this.onOpenSubSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier activeController = controller ?? ref.read(gameProvider.notifier);
    final openSub = onOpenSubSheet ??
        (Widget sheet) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => sheet,
          );
        };

    final activeHabitat =
        activeState.habitats[activeState.activeHabitatId] ?? activeState.habitats.values.first;
    final activeSpecies = Species.fromId(activeHabitat.speciesId);

    final hasCompletedExpedition =
        activeState.expeditions.values.any((e) => e.isCompleted);
    final hasClaimableMission =
        activeState.missions.values.any((m) => m.isCompleted && !m.isClaimed);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF1E3A5A), width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle & Title Row
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Text('🛰️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sanctuary Operations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Operations Cards Grid / List
          Expanded(
            child: ListView(
              children: [
                _buildCard(
                  icon: '🌎',
                  title: 'Global Reserve Map',
                  subtitle: '${activeState.habitats.length} Habitats Active • Travel & Expand',
                  accentColor: const Color(0xFF38BDF8),
                  badge: null,
                  onTap: () {
                    Navigator.of(context).pop();
                    openSub(
                      WorldMapSheet(
                        state: state,
                        onSelectHabitat: (id) =>
                            activeController.switchActiveHabitat(id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildCard(
                  icon: '🧭',
                  title: 'Field Expeditions',
                  subtitle: 'Deploy teams to gather DNA, fossil keys & credits',
                  accentColor: const Color(0xFFFBBF24),
                  badge: hasCompletedExpedition ? 'READY' : null,
                  badgeColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.of(context).pop();
                    openSub(
                      ExpeditionsSheet(
                        state: state,
                        onStartExpedition: (id) =>
                            activeController.startExpedition(id),
                        onClaimExpedition: (id) =>
                            activeController.claimExpedition(id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildCard(
                  icon: '🎯',
                  title: 'Directives & Objectives',
                  subtitle: 'Daily conservation goals & resource bounties',
                  accentColor: const Color(0xFFA78BFA),
                  badge: hasClaimableMission ? 'CLAIM' : null,
                  badgeColor: const Color(0xFFF43F5E),
                  onTap: () {
                    Navigator.of(context).pop();
                    openSub(
                      MissionsSheet(
                        state: state,
                        onClaimMission: (id) =>
                            activeController.claimMissionReward(id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildCard(
                  icon: '🌿',
                  title: 'Ecosystem Restoration',
                  subtitle: 'Prestige active habitat to earn Restoration Seeds & Perks',
                  accentColor: const Color(0xFF4ADE80),
                  badge: 'PRESTIGE',
                  badgeColor: const Color(0xFF047857),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (ctx) => RestorationModal(
                        state: state,
                        habitat: activeHabitat,
                        onConfirmRestore: () {
                          activeController.restoreEcosystem(activeHabitat.id);
                          Navigator.of(ctx).pop();
                        },
                        onBuyPerk: (key) => activeController.buyRestorationPerk(key),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Preferences & Engine Information
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132030),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF20364F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: Color(0xFF94A3B8), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Preferences & Engine Telemetry',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text('🔊', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text(
                                'Sound Effects',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          Switch(
                            value: activeState.soundEnabled,
                            activeColor: const Color(0xFF38BDF8),
                            onChanged: (_) => activeController.toggleSound(),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Species: ${activeSpecies.iconEmoji} ${activeSpecies.name}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Save v${activeState.schemaVersion}',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF132030),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}
