import 'dart:async';

import 'package:flutter/services.dart';

/// Sends optional system haptics.
///
/// Pure Dart unit tests run without a Flutter binding, so the platform channel
/// is unavailable. Detecting that once keeps game logic callable from tests
/// without special-casing every action.
abstract final class GameHaptics {
  static bool? _platformReady;

  static bool get _ready {
    final cached = _platformReady;
    if (cached != null) return cached;
    try {
      ServicesBinding.instance;
      _platformReady = true;
    } catch (_) {
      _platformReady = false;
    }
    return _platformReady!;
  }

  static void light() {
    if (_ready) unawaited(HapticFeedback.lightImpact());
  }

  static void medium() {
    if (_ready) unawaited(HapticFeedback.mediumImpact());
  }

  static void heavy() {
    if (_ready) unawaited(HapticFeedback.heavyImpact());
  }

  static void restore() {
    if (_ready) unawaited(HapticFeedback.vibrate());
  }
}
