import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/models/habitat.dart';
import 'package:extinction_sanctuary/widgets/habitat_viewport.dart';

void main() {
  group('HabitatViewport Widget & Rendering Tests', () {
    Widget buildTestWidget({required Habitat habitat, VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 380,
              height: 280,
              child: HabitatViewport(habitat: habitat, onTap: onTap ?? () {}),
            ),
          ),
        ),
      );
    }

    testWidgets('Builds without exceptions in a sized container', (
      tester,
    ) async {
      const habitat = Habitat(
        id: 'dodo_island',
        name: 'Dodo Island Sanctuary',
        speciesId: 'dodo',
        biomeType: 'tropical_island',
        population: 1,
        level: 1,
      );

      await tester.pumpWidget(buildTestWidget(habitat: habitat));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HabitatViewport), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('🦤'), findsOneWidget);
    });

    testWidgets(
      'Population 0 or invalid values safely render 1 animal without collapse',
      (tester) async {
        const habitat = Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
          biomeType: 'tropical_island',
          population: 0,
          level: 1,
        );

        await tester.pumpWidget(buildTestWidget(habitat: habitat));
        await tester.pump(const Duration(milliseconds: 100));

        // Minimum 1 animal is rendered
        expect(find.text('🦤'), findsOneWidget);
      },
    );

    testWidgets(
      'Large population is capped at maximum visual limit (12 animals)',
      (tester) async {
        const habitat = Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
          biomeType: 'tropical_island',
          population: 150,
          level: 5,
        );

        await tester.pumpWidget(buildTestWidget(habitat: habitat));
        await tester.pump(const Duration(milliseconds: 100));

        // Capped at 12 visual animal widgets
        expect(find.text('🦤'), findsNWidgets(12));
      },
    );

    testWidgets('Builds successfully across all supported biomes', (
      tester,
    ) async {
      const biomes = <String>[
        'tropical_island',
        'australian_forest',
        'northern_coast',
        'african_grasslands',
        'ice_age_tundra',
      ];

      for (final biome in biomes) {
        final habitat = Habitat(
          id: 'test_$biome',
          name: 'Test $biome',
          speciesId: 'dodo',
          biomeType: biome,
          population: 3,
          level: 2,
        );

        await tester.pumpWidget(buildTestWidget(habitat: habitat));
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(HabitatViewport), findsOneWidget);
      }
    });

    testWidgets(
      'Builds successfully across habitat level progression (1, 3, 6, 8)',
      (tester) async {
        const levels = <int>[1, 3, 6, 8];

        for (final level in levels) {
          final habitat = Habitat(
            id: 'test_level_$level',
            name: 'Level $level Habitat',
            speciesId: 'dodo',
            biomeType: 'tropical_island',
            population: 4,
            level: level,
            hasAutoFeeder: level >= 6,
            hasAutoWater: level >= 3,
          );

          await tester.pumpWidget(buildTestWidget(habitat: habitat));
          await tester.pump(const Duration(milliseconds: 50));
          expect(find.byType(HabitatViewport), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Tapping the viewport invokes onTap callback and spawns particles',
      (tester) async {
        var tapCount = 0;
        const habitat = Habitat(
          id: 'dodo_island',
          name: 'Dodo Island Sanctuary',
          speciesId: 'dodo',
          biomeType: 'tropical_island',
          population: 2,
          level: 1,
        );

        await tester.pumpWidget(
          buildTestWidget(habitat: habitat, onTap: () => tapCount++),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Tap the center of the viewport
        await tester.tap(find.byType(HabitatViewport));
        await tester.pump(const Duration(milliseconds: 50));

        expect(tapCount, equals(1));
      },
    );
  });
}
