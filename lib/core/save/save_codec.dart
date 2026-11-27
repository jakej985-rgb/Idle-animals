import 'dart:convert';

import '../../models/game_state.dart';

/// Copies a save into a string the player can keep, and reads it back.
///
/// The payload is the same JSON the game persists, wrapped in a short marker and
/// base64url-encoded so it survives being pasted into notes or messages.
/// [decode] is deliberately strict: a token that is not one of ours, or that is
/// missing the fields a save cannot do without, is rejected instead of being
/// loaded as a half-empty game.
abstract final class SaveCodec {
  static const String prefix = 'EXTINCTION-SANCTUARY-1:';

  static String encode(GameState state) {
    final json = jsonEncode(state.toJson());
    return '$prefix${base64Url.encode(utf8.encode(json))}';
  }

  static GameState? decode(String token) {
    final trimmed = token.trim();
    if (!trimmed.startsWith(prefix)) return null;
    try {
      final payload = trimmed
          .substring(prefix.length)
          .replaceAll(RegExp(r'\s'), '');
      final bytes = base64Url.decode(base64Url.normalize(payload));
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['credits'] is! num) return null;
      if (decoded['habitats'] is! Map) return null;
      return GameState.fromJson(decoded);
    } catch (_) {
      // A truncated or edited token is a paste problem, not a crash.
      return null;
    }
  }
}
