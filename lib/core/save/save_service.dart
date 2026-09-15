import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_state.dart';

class SaveService {
  static const String _saveKey = 'extinction_sanctuary_save_v1';

  Future<void> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.toJson());
      await prefs.setString(_saveKey, jsonStr);
    } catch (e) {
      // In web or headless environments without SharedPreferences backend, fail gracefully
    }
  }

  Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_saveKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return GameState.fromJson(map);
      }
    } catch (e) {
      // Fallback on error
    }
    return null;
  }

  Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
    } catch (_) {}
  }
}
