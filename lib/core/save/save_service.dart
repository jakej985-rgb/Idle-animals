import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_state.dart';

class SaveService {
  static const String _saveKeyV1 = 'extinction_sanctuary_save_v1';
  static const String _saveKeyV2 = 'extinction_sanctuary_save_v2';
  static const String _corruptKey = 'extinction_sanctuary_save_v2_corrupt';

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
    // Kept outside the try so a decode failure can be preserved instead of
    // being silently overwritten by the next autosave.
    String? raw;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check v2 save first
      raw = prefs.getString(_saveKeyV2);

      // Check v1 legacy save if v2 does not exist
      if (raw == null || raw.isEmpty) {
        raw = prefs.getString(_saveKeyV1);
        if (raw != null && raw.isNotEmpty) {
          // Found legacy v1 save; migrate to v2
          final legacyMap = jsonDecode(raw) as Map<String, dynamic>;
          final migratedState = GameState.fromJson(legacyMap).copyWith(
            schemaVersion: GameState.currentSchemaVersion,
          );
          // Persist upgraded v2 save
          await saveGame(migratedState);
          return migratedState;
        }
      }

      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return GameState.fromJson(map);
      }
    } catch (e) {
      // Corruption recovery: return safe initial state rather than crashing,
      // but preserve the unreadable payload first so it can be diagnosed.
      await _backupCorruptSave(raw, e);
      return GameState.initial();
    }
    return null;
  }

  /// Copies an unreadable payload to a side key so the next autosave cannot
  /// destroy the only evidence of what went wrong.
  Future<void> _backupCorruptSave(String? raw, Object error) async {
    // No payload means there was nothing to lose (e.g. storage unavailable).
    if (raw == null || raw.isEmpty) return;
    if (kDebugMode) {
      debugPrint('SaveService: unreadable save ($error); backing up payload.');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_corruptKey, raw);
    } catch (_) {
      // Backup is best-effort; never block recovery.
    }
  }

  Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKeyV1);
      await prefs.remove(_saveKeyV2);
    } catch (e) {
      debugPrint('SaveService: could not clear save ($e).');
    }
  }
}
