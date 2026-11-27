import 'package:material_ui/material_ui.dart';

import '../core/balance/game_balance.dart';
import '../core/format/game_format.dart';
import '../models/habitat.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';

class NeedsPanel extends StatelessWidget {
  final Habitat habitat;
  final double credits;
  final double dna;
  final VoidCallback onFeed;
  final VoidCallback onWater;
  final VoidCallback onRevive;

  /// Compact mode is used by the sanctuary screen on short viewports. It keeps
  /// the population summary, needs and welfare readable in about half the
  /// vertical space of the regular panel.
  final bool compact;

  const NeedsPanel({
    super.key,
    required this.habitat,
    required this.credits,
    required this.dna,
    required this.onFeed,
    required this.onWater,
    required this.onRevive,
    this.compact = false,
  });

  String _getHappinessText(double happiness) {
    if (happiness >= 85) return 'Thriving 🥰 (+20% Output)';
    if (happiness >= 60) return 'Content 😊 (Normal)';
    if (happiness >= 40) return 'Needs Attention 😐 (-25%)';
    return 'Unhappy 🥺 (Low Output)';
  }

  Color _getHappinessColor(double happiness) {
    if (happiness >= 85) return AppColors.success;
    if (happiness >= 60) return AppColors.accent;
    if (happiness >= 40) return AppColors.amber;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final species = Species.fromId(habitat.speciesId);
    final bool canRevive =
        dna >= GameBalance.reviveCostDna &&
        habitat.population < habitat.capacity;
    final bool bothAutomated = habitat.hasAutoFeeder && habitat.hasAutoWater;

    final body = bothAutomated
        ? _buildAutomationSummary()
        : compact
        ? _buildCompactBody(species, canRevive)
        : _buildFullBody(species, canRevive);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: body,
    );
  }

  Widget _buildFullBody(Species species, bool canRevive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPopulationHeader(species, canRevive, compact: false),
        const SizedBox(height: 14),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 14),
        _buildManualNeeds(),
        const SizedBox(height: 12),
        _buildWelfareRow(),
      ],
    );
  }

  Widget _buildCompactBody(Species species, bool canRevive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPopulationHeader(species, canRevive, compact: true),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCompactNeed(
                icon: '🍎',
                label: 'Food',
                percent: habitat.foodPercentage,
                color: AppColors.quince,
                isAuto: habitat.hasAutoFeeder,
                actionLabel: _feedActionLabel,
                enabled: _canFeed,
                onAction: onFeed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactNeed(
                icon: '💧',
                label: 'Water',
                percent: habitat.waterPercentage,
                color: AppColors.accent,
                isAuto: habitat.hasAutoWater,
                actionLabel: 'Pump',
                enabled: true,
                onAction: onWater,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildWelfareRow(),
      ],
    );
  }

  Widget _buildAutomationSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPopulationHeader(
          Species.fromId(habitat.speciesId),
          dna >= GameBalance.reviveCostDna &&
              habitat.population < habitat.capacity,
          compact: true,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _autoChip('🍎', 'Feeder auto'),
            _autoChip('💧', 'Water auto'),
          ],
        ),
        const SizedBox(height: 8),
        _buildWelfareRow(),
      ],
    );
  }

  Widget _autoChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPopulationHeader(
    Species species,
    bool canRevive, {
    required bool compact,
  }) {
    final isAtCapacity = habitat.population >= habitat.capacity;
    final populationColor = isAtCapacity ? AppColors.amber : AppColors.success;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            species.iconEmoji,
            style: TextStyle(fontSize: compact ? 18 : 22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${species.name} Population',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${habitat.population} / ${habitat.capacity}',
                    style: TextStyle(
                      color: populationColor,
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w800,
                      fontFeatures: AppText.tabularFigures,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _AnimatedBar(
                value: isAtCapacity ? 1.0 : habitat.breedingProgress,
                color: isAtCapacity ? AppColors.amber : AppColors.emerald,
                height: 7,
              ),
              const SizedBox(height: 4),
              Text(
                isAtCapacity
                    ? 'Capacity reached. Expand the reserve in Upgrades.'
                    : 'Next ${species.name} breeding: ${(habitat.breedingProgress * 100).toStringAsFixed(0)}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isAtCapacity ? AppColors.amber : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildReviveButton(canRevive, compact: compact),
      ],
    );
  }

  Widget _buildReviveButton(bool canRevive, {required bool compact}) {
    final tooltip = canRevive
        ? 'Revive a ${Species.fromId(habitat.speciesId).name} for '
              '${GameFormat.whole(GameBalance.reviveCostDna)} DNA'
        : 'Revive needs ${GameFormat.whole(GameBalance.reviveCostDna)} DNA '
              'and free capacity';

    if (compact) {
      return Tooltip(
        message: tooltip,
        child: IconButton.filledTonal(
          onPressed: canRevive ? onRevive : null,
          icon: const Text('🧬', style: TextStyle(fontSize: 18)),
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: AppColors.primary.withValues(alpha: 0.18),
            disabledBackgroundColor: AppColors.surfaceRaised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: canRevive ? onRevive : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(72, 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧬 Revive',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '${GameFormat.whole(GameBalance.reviveCostDna)} DNA',
              style: const TextStyle(fontSize: 10, color: Color(0xFFBAE6FD)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualNeeds() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildNeedBar(
            icon: '🍎',
            label: 'Food',
            percent: habitat.foodPercentage,
            color: AppColors.quince,
            isAuto: habitat.hasAutoFeeder,
            onAction: onFeed,
            actionLabel: _feedActionLabel,
            enabled: _canFeed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildNeedBar(
            icon: '💧',
            label: 'Water',
            percent: habitat.waterPercentage,
            color: AppColors.accent,
            isAuto: habitat.hasAutoWater,
            onAction: onWater,
            actionLabel: 'Pump Pool',
            enabled: true,
          ),
        ),
      ],
    );
  }

  bool get _canFeed => credits >= GameBalance.feedCostCredits || credits <= 0;

  String get _feedActionLabel {
    final cost = GameFormat.whole(GameBalance.feedCostCredits);
    if (credits <= 0) return 'Emergency feed';
    if (credits < GameBalance.feedCostCredits) return 'Need $cost 🪙';
    return 'Feed ($cost🪙)';
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
    return Semantics(
      container: true,
      label:
          '$label: ${(percent * 100).toStringAsFixed(0)} percent'
          '${isAuto ? ', automated' : ''}',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isAuto)
                    _autoBadge()
                  else
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFeatures: AppText.tabularFigures,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: _AnimatedBar(value: percent, color: color, height: 6),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: isAuto || !enabled ? null : onAction,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: isAuto
                        ? AppColors.border
                        : color.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  isAuto ? 'Automated' : actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (isAuto || !enabled) ? AppColors.textSubdued : color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactNeed({
    required String icon,
    required String label,
    required double percent,
    required Color color,
    required bool isAuto,
    required String actionLabel,
    required bool enabled,
    required VoidCallback onAction,
  }) {
    return Semantics(
      container: true,
      label:
          '$label: ${(percent * 100).toStringAsFixed(0)} percent'
          '${isAuto ? ', automated' : ''}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    isAuto ? 'AUTO' : '${(percent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isAuto ? AppColors.success : color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFeatures: AppText.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ExcludeSemantics(
              child: _AnimatedBar(value: percent, color: color, height: 5),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: isAuto || !enabled ? null : onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  isAuto ? 'Automated' : actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _autoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        'AUTO',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWelfareRow() {
    final color = _getHappinessColor(habitat.happiness);
    return Semantics(
      container: true,
      label:
          'Welfare ${habitat.happiness.toStringAsFixed(0)} percent. '
          '${_getHappinessText(habitat.happiness)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                'Welfare: ${habitat.happiness.toStringAsFixed(0)}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFeatures: AppText.tabularFigures,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _getHappinessText(habitat.happiness),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _AnimatedBar({
    required this.value,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: AppColors.track,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}
