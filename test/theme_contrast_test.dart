import 'dart:math' as math;

import 'package:extinction_sanctuary/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 relative luminance of an opaque color.
double _relativeLuminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// WCAG 2.1 contrast ratio between two opaque colors, in the range 1..21.
double _contrastRatio(Color a, Color b) {
  final luminanceA = _relativeLuminance(a);
  final luminanceB = _relativeLuminance(b);
  final lighter = math.max(luminanceA, luminanceB);
  final darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

const _surfaces = <String, Color>{
  'background': AppColors.background,
  'surface': AppColors.surface,
  'surfaceAlt': AppColors.surfaceAlt,
  'surfaceRaised': AppColors.surfaceRaised,
  'surfaceHighlight': AppColors.surfaceHighlight,
  'sheet': AppColors.sheet,
  'bottom': AppColors.bottom,
};

/// Tokens used to paint text on a surface. `AppColors.primary` is absent here
/// because it is a fill, not a text color; fills that carry text are covered by
/// the on-fill group below.
const _textTokens = <String, Color>{
  'textPrimary': AppColors.textPrimary,
  'textSecondary': AppColors.textSecondary,
  'textMuted': AppColors.textMuted,
  'accent': AppColors.accent,
  'success': AppColors.success,
  'amber': AppColors.amber,
  'danger': AppColors.danger,
  'emerald': AppColors.emerald,
  'purple': AppColors.purple,
  'quince': AppColors.quince,
};

/// Fills that carry text: badges, chips and button backgrounds. Their
/// foreground comes from `AppColors.onFill`, never a hardcoded white.
const _fillTokens = <String, Color>{
  'primary': AppColors.primary,
  'accent': AppColors.accent,
  'emerald': AppColors.emerald,
  'success': AppColors.success,
  'amber': AppColors.amber,
  'quince': AppColors.quince,
  'purple': AppColors.purple,
  'danger': AppColors.danger,
};

/// Tokens used as indicators (badges, bars, borders, icons). These are
/// non-text UI, so WCAG 1.4.11 requires 3:1 rather than the 4.5:1 text minimum.
const _indicatorTokens = <String, Color>{
  'accent': AppColors.accent,
  'success': AppColors.success,
  'amber': AppColors.amber,
  'danger': AppColors.danger,
  'emerald': AppColors.emerald,
  'purple': AppColors.purple,
  'quince': AppColors.quince,
};

void main() {
  group('Palette Contrast Tests', () {
    test('contrast helper matches WCAG reference values', () {
      // Sanity check the arithmetic every other assertion depends on.
      expect(_contrastRatio(Colors.white, Colors.black), closeTo(21.0, 0.01));
      expect(_contrastRatio(Colors.white, Colors.white), closeTo(1.0, 0.001));
      // Neutral mid-grey against white: 4.48:1, the usual AA boundary probe.
      expect(
        _contrastRatio(const Color(0xFF777777), Colors.white),
        closeTo(4.48, 0.01),
      );
    });

    test('body text tokens clear 4.5:1 on every surface', () {
      final failures = <String>[];
      for (final text in _textTokens.entries) {
        for (final surface in _surfaces.entries) {
          final ratio = _contrastRatio(text.value, surface.value);
          if (ratio < 4.5) {
            failures.add(
              '${text.key} on ${surface.key} = ${ratio.toStringAsFixed(2)}:1',
            );
          }
        }
      }

      expect(
        failures,
        isEmpty,
        reason: 'Text colors must stay AA-readable on every surface. A color '
            'that cannot reach 4.5:1 is a disabled/inactive-only tier and '
            'belongs in AppColors.textSubdued, not in this list.',
      );
    });

    test('text on filled badges, chips and buttons clears 4.5:1', () {
      // Badge labels run as small as 9px, so even the bold ones are "normal"
      // text under WCAG 1.4.3. AppColors.onFill must beat a flat white on every
      // fill, and the winner has to actually pass.
      final failures = <String>[];
      for (final fill in _fillTokens.entries) {
        final foreground = AppColors.onFill(fill.value);
        final ratio = _contrastRatio(foreground, fill.value);
        final whiteRatio = _contrastRatio(Colors.white, fill.value);
        final darkRatio = _contrastRatio(AppColors.background, fill.value);

        if (ratio < 4.5) {
          failures.add(
            '${fill.key} needs 4.5:1 but onFill only reaches '
            '${ratio.toStringAsFixed(2)}:1',
          );
        }
        if (ratio < math.max(whiteRatio, darkRatio) - 0.001) {
          failures.add(
            '${fill.key} picked a worse foreground than the best candidate',
          );
        }
      }

      expect(
        failures,
        isEmpty,
        reason: 'A fill that cannot carry either white or background text at '
            '4.5:1 needs a darker or lighter token, not a hardcoded white label.',
      );
    });

    test('textSubdued holds at least 3:1 for inactive controls', () {
      // textSubdued tops out near 4:1 by design, so it may only paint disabled
      // or inactive controls, which WCAG 1.4.3 exempts. If it is ever used for
      // active text, raise the token itself until this floor reaches 4.5.
      final failures = <String>[];
      for (final surface in _surfaces.entries) {
        final ratio = _contrastRatio(AppColors.textSubdued, surface.value);
        if (ratio < 3.0) {
          failures.add(
            'textSubdued on ${surface.key} = ${ratio.toStringAsFixed(2)}:1',
          );
        }
      }

      expect(failures, isEmpty, reason: 'Inactive labels still need to be seen.');
    });

    test('indicator tokens clear 3:1 as non-text UI', () {
      final failures = <String>[];
      for (final indicator in _indicatorTokens.entries) {
        for (final surface in _surfaces.entries) {
          final ratio = _contrastRatio(indicator.value, surface.value);
          if (ratio < 3.0) {
            failures.add(
              '${indicator.key} on ${surface.key} = ${ratio.toStringAsFixed(2)}:1',
            );
          }
        }
      }

      expect(
        failures,
        isEmpty,
        reason: 'Badges, bars and icons must stay distinguishable from the '
            'surface behind them.',
      );
    });

    test('text emphasis ramp keeps a decreasing contrast order', () {
      const ramp = <(String, Color)>[
        ('textPrimary', AppColors.textPrimary),
        ('textSecondary', AppColors.textSecondary),
        ('textMuted', AppColors.textMuted),
        ('textSubdued', AppColors.textSubdued),
      ];

      for (final surface in _surfaces.entries) {
        for (var i = 0; i < ramp.length - 1; i++) {
          final stronger = _contrastRatio(ramp[i].$2, surface.value);
          final weaker = _contrastRatio(ramp[i + 1].$2, surface.value);

          expect(
            stronger,
            greaterThan(weaker),
            reason: '${ramp[i].$1} must read stronger than ${ramp[i + 1].$1} on '
                '${surface.key}, otherwise the emphasis ramp collapses.',
          );
        }
      }
    });
  });
}
