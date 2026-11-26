import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/offline/offline_manager.dart';
import '../models/habitat.dart';
import '../models/species.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_header.dart';
import '../widgets/habitat_viewport.dart';
import '../widgets/needs_panel.dart';
import '../widgets/offline_modal.dart';
import 'expeditions_sheet.dart';
import 'missions_sheet.dart';
import 'operations_sheet.dart';
import 'world_map_sheet.dart';

class SanctuaryScreen extends ConsumerStatefulWidget {
  /// Forwarded to [HabitatViewport] so golden tests can freeze the animation.
  final int? viewportSeed;

  const SanctuaryScreen({super.key, this.viewportSeed});

  @override
  ConsumerState<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends ConsumerState<SanctuaryScreen> {
  /// Which offline report already opened its modal. Each resume produces a new
  /// report instance, so identity distinguishes a second backgrounded session
  /// from the one already shown (a plain bool would stay latched).
  OfflineReport? _shownOfflineReport;
  final GlobalKey _viewportKey = GlobalKey();

  void _revealViewport() {
    final ctx = _viewportKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    // Show the offline progress modal once per report. The marker is set here
    // rather than in the callback so a rebuild before the frame cannot queue a
    // second dialog.
    final pendingReport = controller.pendingOfflineReport;
    if (pendingReport != null &&
        !identical(pendingReport, _shownOfflineReport)) {
      _shownOfflineReport = pendingReport;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => OfflineModal(
            report: pendingReport,
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

    final hasCompletedExpedition =
        state.expeditions.values.any((e) => e.isCompleted);
    final hasClaimableMission =
        state.missions.values.any((m) => m.isCompleted && !m.isClaimed);

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Short or large-text viewports switch to a scrollable compact
            // composition so the viewport never collapses below a usable size.
            final compact =
                constraints.maxHeight < 680 || textScale > 1.15;
            final horizontalPadding = compact ? 12.0 : 16.0;

            final header = CurrencyHeader(state: state);
            final habitatHeader = _buildHabitatHeader(
              context,
              habitat,
              hasCompletedExpedition || hasClaimableMission,
            );
            final viewport = HabitatViewport(
              habitat: habitat,
              seed: widget.viewportSeed,
              onTap: () => controller.petAnimals(habitat.id),
            );
            final needs = NeedsPanel(
              habitat: habitat,
              credits: state.credits,
              dna: state.dna,
              onFeed: () => controller.feedHabitat(habitat.id),
              onWater: () => controller.waterHabitat(habitat.id),
              onRevive: () => controller.reviveSpecies(habitat.id),
              compact: compact,
            );
            final dock = _buildDock(
              context,
              hasExpeditionBadge: hasCompletedExpedition,
              hasMissionBadge: hasClaimableMission,
            );

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 6 : 8,
                  horizontalPadding,
                  compact ? 6 : 8,
                ),
                child: compact
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            header,
                            const SizedBox(height: 8),
                            habitatHeader,
                            const SizedBox(height: 8),
                            SizedBox(
                              key: _viewportKey,
                              height: math.max(
                                210,
                                constraints.maxHeight * 0.34,
                              ),
                              child: viewport,
                            ),
                            const SizedBox(height: 8),
                            needs,
                            const SizedBox(height: 10),
                            dock,
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          header,
                          const SizedBox(height: 8),
                          habitatHeader,
                          const SizedBox(height: 8),
                          Expanded(child: viewport),
                          const SizedBox(height: 8),
                          needs,
                          const SizedBox(height: 10),
                          dock,
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitatHeader(
    BuildContext context,
    Habitat habitat,
    bool hasAlertBadge,
  ) {
    final species = Species.fromId(habitat.speciesId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(_getBiomeEmoji(habitat.biomeType),
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        habitat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Lv ${habitat.level}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${species.iconEmoji} ${species.name} • Pop: ${habitat.population}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildOperationsButton(context, hasAlertBadge),
        ],
      ),
    );
  }

  Widget _buildOperationsButton(BuildContext context, bool hasAlertBadge) {
    return Tooltip(
      message: 'Open sanctuary operations',
      child: Semantics(
        button: true,
        label: 'Open sanctuary operations',
        child: InkWell(
          onTap: () => _openSheet(
            context,
            OperationsSheet(
              onOpenSubSheet: (sheet) => _openSheet(context, sheet),
            ),
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🛰️', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Operations',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAlertBadge)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Semantics(
                    label: 'New activity available',
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDock(
    BuildContext context, {
    required bool hasExpeditionBadge,
    required bool hasMissionBadge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bottom,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // The dock surface is painted by this container, so ink effects need a
      // Material above it to be visible.
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            _buildDockButton(
              icon: '🏝️',
              label: 'Reserve',
              isSelected: true,
              onTap: _revealViewport,
            ),
            _buildDockButton(
              icon: '🧭',
              label: 'Expeditions',
              badge: hasExpeditionBadge,
              onTap: () => _openSheet(context, const ExpeditionsSheet()),
            ),
            _buildDockButton(
              icon: '🎯',
              label: 'Directives',
              badge: hasMissionBadge,
              onTap: () => _openSheet(context, const MissionsSheet()),
            ),
            _buildDockButton(
              icon: '⚙️',
              label: 'Operations',
              onTap: () => _openSheet(
                context,
                OperationsSheet(
                  onOpenSubSheet: (sheet) => _openSheet(context, sheet),
                ),
              ),
            ),
            _buildDockButton(
              icon: '🌎',
              label: 'Map',
              onTap: () => _openSheet(context, const WorldMapSheet()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockButton({
    required String icon,
    required String label,
    bool isSelected = false,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.accent : AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label${badge ? ', new activity' : ''}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Ink(
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (badge)
                  Positioned(
                    top: 4,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.82,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(ctx).bottom,
              ),
              child: MediaQuery.removePadding(
                context: ctx,
                removeBottom: true,
                child: sheet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
