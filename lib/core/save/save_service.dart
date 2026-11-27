import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/game_state.dart';

class SaveService {
  static const String _saveKeyV1 = 'extinction_sanctuary_save_v1';
  static const String _saveKeyV2 = 'extinction_sanctuary_save_v2';
  static const String _backupKey = 'extinction_sanctuary_save_v2_backup';
  static const String _corruptKey = 'extinction_sanctuary_save_v2_corrupt';

  /// Writes are chained so saves issued in the same frame land in the order they
  /// were requested, and a slow write cannot overtake a newer snapshot.
  Future<void> _writes = Future<void>.value();

  Future<void> saveGame(GameState state) {
    // Encode now: the payload has to be the state at call time, not whatever
    // the state has become by the time the queue reaches this write.
    final payload = jsonEncode(state.toJson());
    final write = _writes.then((_) => _write(payload));
    _writes = write;
    return write;
  }

  Future<void> _write(String payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Rotate the previous payload first: if the next payload turns out to be
      // unreadable, the player still has one good save to fall back to.
      final previous = prefs.getString(_saveKeyV2);
      if (previous != null && previous.isNotEmpty) {
        await prefs.setString(_backupKey, previous);
      }
      await prefs.setString(_saveKeyV2, payload);
    } catch (error) {
      // A device that cannot persist progress looks perfectly normal from the
      // outside, so a failed write is reported instead of swallowed.
      debugPrint(
        'SaveService: could not persist the save (${_firstLine(error)}).',
      );
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
          final migratedState = GameState.fromJson(legacyMap)
              .copyWith(schemaVersion: GameState.currentSchemaVersion);
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
      // Corruption recovery: preserve the unreadable payload, then try the
      // previous save before giving up on the player's progress entirely.
      await _backupCorruptSave(raw, e);
      final recovered = await _loadBackup();
      if (recovered != null) return recovered;
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

  /// Reads the save written just before the unreadable one and promotes it back
  /// to the live slot, so the next launch loads normally instead of repeating
  /// the recovery.
  Future<GameState?> _loadBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_backupKey);
      if (raw == null || raw.isEmpty) return null;
      final state = GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await prefs.setString(_saveKeyV2, raw);
      debugPrint('SaveService: recovered the previous save.');
      return state;
    } catch (error) {
      debugPrint(
        'SaveService: the backup save was unreadable too '
        '(${_firstLine(error)}).',
      );
      return null;
    }
  }

  /// Platform exceptions carry multi-line explanations; the log only needs the
  /// reason.
  static String _firstLine(Object error) => error.toString().split('\n').first;

  Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKeyV1);
      await prefs.remove(_saveKeyV2);
      // A reset must not be undone by backup recovery on the next launch.
      await prefs.remove(_backupKey);
    } catch (e) {
      debugPrint('SaveService: could not clear save ($e).');
    }
  }
}
