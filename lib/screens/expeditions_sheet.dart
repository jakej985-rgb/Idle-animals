import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/format/game_format.dart';
import '../models/expedition.dart';
import '../models/fossil.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_header.dart';

class ExpeditionsSheet extends ConsumerWidget {
  final GameState? state;
  final Function(String)? onStartExpedition;
  final Function(String)? onClaimExpedition;

  const ExpeditionsSheet({
    super.key,
    this.state,
    this.onStartExpedition,
    this.onClaimExpedition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState activeState = state ?? ref.watch(gameProvider);
    final GameNotifier controller = ref.read(gameProvider.notifier);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final exps = activeState.expeditions.values.toList();
    final fossils = activeState.fossilInventory.values.toList();

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
            icon: '🧭',
            title: 'Fossil Expeditions',
            subtitle:
                'Dispatch field teams to recover preserved bones, amber and ancient genomes.',
            trailing: Text(
              '🪙 ${GameFormat.compact(activeState.credits)}',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFeatures: AppText.tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Fossil Inventory Quick Summary Bar
          if (fossils.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('🦴 Discoveries: ',
                      style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: fossils.map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: const Color(0xFF162534),
                              avatar: Text(f.iconEmoji,
                                  style: const TextStyle(fontSize: 12)),
                              label: Text('${f.name} (x${f.count})',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white70)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: ListView(
              children: exps.map((exp) {
                return _buildExpeditionCard(
                    context, exp, nowMs, activeState, controller);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpeditionCard(BuildContext context, Expedition exp, int nowMs,
      GameState activeState, GameNotifier controller) {
    final canAfford = activeState.credits >= exp.creditsCost;
    final isDone = exp.isCompleted || exp.checkCompleted(nowMs);
    final remainingSec = exp.getRemainingSeconds(nowMs);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDone
              ? AppColors.emerald
              : (exp.isActive
                  ? AppColors.primary
                  : AppColors.border),
          width: (isDone || exp.isActive) ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF15222E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(exp.iconEmoji,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            exp.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (exp.unlocksSpeciesId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🧬 SPECIES',
                              style: TextStyle(
                                color: AppColors.purple,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exp.region} • ${exp.durationSeconds.toStringAsFixed(0)}s travel',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exp.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 10),

          // Potential Finds Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: exp.possibleFinds.map((find) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF131F2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  '${find.iconEmoji} ${find.name}',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getRarityColor(find.rarity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Active Timer or Dispatch Button
          if (exp.isActive && !isDone) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 1.0 - (remainingSec / exp.durationSeconds),
                minHeight: 6,
                backgroundColor: AppColors.track,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Team surveying terrain... ${remainingSec.toStringAsFixed(0)}s remaining',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (isDone) ...[
            ElevatedButton(
              onPressed: () {
                if (onClaimExpedition != null) {
                  onClaimExpedition!(exp.id);
                } else {
                  controller.claimExpedition(exp.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'CLAIM EXPEDITION DISCOVERIES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: canAfford
                  ? () {
                      if (onStartExpedition != null) {
                        onStartExpedition!(exp.id);
                      } else {
                        controller.startExpedition(exp.id);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.track,
                disabledForegroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧭', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    'Dispatch Team (🪙 ${exp.creditsCost.toStringAsFixed(0)})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRarityColor(FossilRarity rarity) {
    switch (rarity) {
      case FossilRarity.uncommon:
        return AppColors.success;
      case FossilRarity.rare:
        return AppColors.accent;
      case FossilRarity.legendary:
        return AppColors.amber;
      default:
        return const Color(0xFFCBD5E1);
    }
  }
}
