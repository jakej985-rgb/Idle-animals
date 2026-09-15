import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_notifier.dart';
import '../widgets/currency_header.dart';
import '../widgets/habitat_viewport.dart';
import '../widgets/needs_panel.dart';
import '../widgets/offline_modal.dart';
import 'archive_sheet.dart';
import 'research_sheet.dart';
import 'staff_sheet.dart';
import 'upgrades_sheet.dart';

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

    final habitat = state.habitats['dodo_island']!;

    return Scaffold(
      backgroundColor: const Color(0xFF070E17),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 1. Top Header: Currencies & Live Rates
                    CurrencyHeader(state: state),
                    const SizedBox(height: 10),

                    // 2. Habitat Title & Status Badge
                    Row(
                      children: [
                        const Text('🏝️', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          habitat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
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

                    // 3. Living Dodo Island Viewport
                    Expanded(
                      flex: 5,
                      child: HabitatViewport(
                        habitat: habitat,
                        onTap: () => controller.petDodos('dodo_island'),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. Animal Needs & Breeding Panel
                    NeedsPanel(
                      habitat: habitat,
                      credits: state.credits,
                      dna: state.dna,
                      onFeed: () => controller.feedHabitat('dodo_island'),
                      onWater: () => controller.waterHabitat('dodo_island'),
                      onRevive: () => controller.reviveDodo('dodo_island'),
                    ),
                    const SizedBox(height: 12),

                    // 5. Navigation Action Dock
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

  Widget _buildDock(
    BuildContext context,
    dynamic state,
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

  void _openSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.75,
        child: sheet,
      ),
    );
  }
}
