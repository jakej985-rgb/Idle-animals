import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:extinction_sanctuary/models/species.dart';
import 'package:extinction_sanctuary/screens/upgrades_sheet.dart';
import 'package:extinction_sanctuary/screens/world_map_sheet.dart';
import 'package:extinction_sanctuary/widgets/currency_header.dart';
import 'package:extinction_sanctuary/widgets/habitat_viewport.dart';
import 'package:extinction_sanctuary/widgets/needs_panel.dart';
import 'package:extinction_sanctuary/widgets/restoration_modal.dart';

void main() {
  group('Phase 1: Reactivity & Quick Wins UI/UX Tests', () {
    testWidgets(
      'NeedsPanel dynamically renders species name and icon for non-dodo species',
      (tester) async {
        const thylacineHabitat = Habitat(
          id: 'tasman_forest',
          name: 'Tasmanian Forest Reserve',
          speciesId: 'thylacine',
          biomeType: 'temperate_forest',
          population: 5,
          level: 2,
          food: 80.0,
          water: 70.0,
          happiness: 90.0,
        );

        final species = Species.fromId('thylacine');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeedsPanel(
                habitat: thylacineHabitat,
                credits: 1000.0,
                dna: 50.0,
                onFeed: () {},
                onWater: () {},
                onRevive: () {},
              ),
            ),
          ),
        );

        // Verify that the species emoji, name, and capacity are displayed dynamically
        expect(find.text(species.iconEmoji), findsOneWidget);
        expect(find.text('${species.name} Population'), findsOneWidget);
        expect(find.text('5 / 40'), findsOneWidget);
      },
    );

    testWidgets(
      'CurrencyHeader displays cumulative generation across all active habitats',
      (tester) async {
        // Create a state with 2 habitats: Dodo Island (pop 10) and Tasman Forest (pop 5)
        final state = GameState.initial().copyWith(
          habitats: {
            'dodo_island': const Habitat(
              id: 'dodo_island',
              name: 'Dodo Island Sanctuary',
              speciesId: 'dodo',
              biomeType: 'tropical_island',
              population: 10,
              level: 1,
            ),
            'tasman_forest': const Habitat(
              id: 'tasman_forest',
              name: 'Tasmanian Forest Reserve',
              speciesId: 'thylacine',
              biomeType: 'temperate_forest',
              population: 5,
              level: 1,
            ),
          },
        );

        // Expected rates (at 100 happiness):
        // Credits: 10 * 1.0 (dodo) + 5 * 2.5 (thylacine) = 22.5/s
        // DNA: 10 * 0.4 (dodo) + 5 * 0.9 (thylacine) = 8.5/s
        // Research: 10 * 0.25 (dodo) + 5 * 0.60 (thylacine) = 5.5/s

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CurrencyHeader(state: state)),
          ),
        );

        expect(find.text('+22.5/s'), findsOneWidget);
        expect(find.text('+8.5/s'), findsOneWidget);
        expect(find.text('+5.5/s'), findsOneWidget);
      },
    );

    testWidgets(
      'HabitatViewport renders animal sprites with Transform directionality',
      (tester) async {
        const habitat = Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
          biomeType: 'tropical_island',
          population: 4,
          level: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: HabitatViewport(habitat: habitat, onTap: () {}),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Should find Transform widgets wrapping the animal icons
        final transformFinder = find.descendant(
          of: find.byType(HabitatViewport),
          matching: find.byType(Transform),
        );
        expect(transformFinder, findsWidgets);
      },
    );

    testWidgets('UpgradesSheet is reactive when used inside ProviderScope', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: UpgradesSheet())),
        ),
      );

      expect(find.text('Sanctuary Upgrades'), findsOneWidget);
      expect(find.text('Solar Automated Feeder'), findsOneWidget);
      expect(find.text('Spring Fresh-Flow Pump'), findsOneWidget);
    });

    testWidgets('WorldMapSheet allows viewing regional habitats reactively', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: WorldMapSheet())),
        ),
      );

      expect(find.text('Global Sanctuary Network'), findsOneWidget);
      expect(find.text('Dodo Island Sanctuary'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Tasmanian Forest Reserve'), findsOneWidget);
    });

    testWidgets('RestorationModal renders correctly with permanent perks', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: RestorationModal())),
        ),
      );

      expect(find.text('Permanent Global Perks'), findsOneWidget);
      expect(find.text('Species Growth Boost'), findsOneWidget);
      expect(find.text('Ancient DNA Synthesis'), findsOneWidget);
      expect(find.text('Conservation Research Lab'), findsOneWidget);
      expect(find.text('Field Radar Vehicles'), findsOneWidget);
    });
  });
}
