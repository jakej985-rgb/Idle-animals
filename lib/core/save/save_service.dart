import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_state.dart';

class SaveService {
  static const String _saveKeyV1 = 'extinction_sanctuary_save_v1';
  static const String _saveKeyV2 = 'extinction_sanctuary_save_v2';

  Future<void> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.toJson());
      // Atomic write to current version key
      await prefs.setString(_saveKeyV2, jsonStr);
    } catch (e) {
      // Fail gracefully in restricted environments
    }
  }

  Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check v2 save first
      String? jsonStr = prefs.getString(_saveKeyV2);

      // Check v1 legacy save if v2 does not exist
      if (jsonStr == null || jsonStr.isEmpty) {
        jsonStr = prefs.getString(_saveKeyV1);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          // Found legacy v1 save; migrate to v2
          final legacyMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          final migratedState = GameState.fromJson(legacyMap).copyWith(
            schemaVersion: GameState.currentSchemaVersion,
          );
          // Persist upgraded v2 save
          await saveGame(migratedState);
          return migratedState;
        }
      }

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return GameState.fromJson(map);
      }
    } catch (e) {
      // Corruption recovery: return safe initial state rather than crashing
      return GameState.initial();
    }
    return null;
  }

  Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKeyV1);
      await prefs.remove(_saveKeyV2);
    } catch (_) {}
  }
}
