import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:extinction_sanctuary/core/save/save_service.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveService Migration & Corruption Recovery Tests', () {
    test('Migrates legacy v1 save payload to v2 schema seamlessly', () async {
      // Create legacy save data (schemaVersion missing, totalDodosBred present)
      final initial = GameState.initial();
      final legacyJsonMap = initial.toJson();
      legacyJsonMap.remove('schemaVersion');
      legacyJsonMap['totalDodosBred'] = 42;
      legacyJsonMap.remove('totalAnimalsBred');

      final legacyString = jsonEncode(legacyJsonMap);

      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v1': legacyString,
      });

      final saveService = SaveService();
      final loaded = await saveService.loadGame();

      expect(loaded, isNotNull);
      expect(loaded!.schemaVersion, equals(2));
      expect(loaded.totalAnimalsBred, equals(42));
      expect(loaded.totalDodosBred, equals(42)); // backward compatible alias

      // Verify v2 save key is now written
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('extinction_sanctuary_save_v2'), isTrue);
    });

    test('Recovers gracefully from corrupted save JSON without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'extinction_sanctuary_save_v2': '{corrupted_malformed_json_###',
      });

      final saveService = SaveService();
      final recovered = await saveService.loadGame();

      // Rather than crashing with FormatException, returns safe initial state
      expect(recovered, isNotNull);
      expect(recovered!.credits, equals(60.0));
      expect(recovered.schemaVersion, equals(2));
    });
  });
}
