import 'dart:math' as math;

import 'package:extinction_sanctuary/theme/app_theme.dart';
import 'package:flutter/material.dart';
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

/// Tokens used to paint text. `AppColors.primary` is deliberately absent: it is
/// a fill token (progress bars, button backgrounds), not a text color.
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
      expect(
        _contrastRatio(const Color(0xFFF8FAFC), AppColors.background),
        closeTo(18.51, 0.05),
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
