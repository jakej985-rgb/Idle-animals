import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/species.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/restoration_modal.dart';
import '../widgets/sheet_header.dart';
import 'archive_sheet.dart';
import 'expeditions_sheet.dart';
import 'missions_sheet.dart';
import 'research_sheet.dart';
import 'staff_sheet.dart';
import 'upgrades_sheet.dart';
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
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border(top: BorderSide(color: AppColors.borderStrong, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHeader(
            icon: '🛰️',
            title: 'Sanctuary Operations',
            subtitle: 'Reserve network, field teams and sanctuary services',
          ),
          const SizedBox(height: 14),

          // Operations Cards Grid / List
          Expanded(
            child: ListView(
              children: [
                const Text('Sanctuary Services', style: AppText.overline),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildServiceButton(
                      icon: '⭐',
                      label: 'Upgrades',
                      onTap: () => _openService(context, openSub, const UpgradesSheet()),
                    ),
                    _buildServiceButton(
                      icon: '🧑‍🌾',
                      label: 'Staff',
                      onTap: () => _openService(context, openSub, const StaffSheet()),
                    ),
                    _buildServiceButton(
                      icon: '🔬',
                      label: 'Research',
                      onTap: () => _openService(context, openSub, const ResearchSheet()),
                    ),
                    _buildServiceButton(
                      icon: '📜',
                      label: 'Archive',
                      onTap: () => _openService(context, openSub, const ArchiveSheet()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                          Expanded(
                            child: Text(
                              'Preferences & Engine Telemetry',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
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
                              Text('📳', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text(
                                'Haptic Feedback',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          Switch(
                            value: activeState.hapticsEnabled,
                            onChanged: (_) => activeController.toggleHaptics(),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Active Species: ${activeSpecies.iconEmoji} ${activeSpecies.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
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

  void _openService(
    BuildContext context,
    void Function(Widget sheet) openSub,
    Widget sheet,
  ) {
    Navigator.of(context).pop();
    openSub(sheet);
  }

  Widget _buildServiceButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
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
