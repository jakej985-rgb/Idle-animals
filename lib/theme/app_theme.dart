import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central palette for the sanctuary UI.
///
/// Widgets should consume these tokens instead of embedding hex literals so
/// that contrast and surface hierarchy can be tuned in one place.
abstract final class AppColors {
  static const background = Color(0xFF070E17);
  static const surface = Color(0xFF101924);
  static const surfaceAlt = Color(0xFF0C141D);
  static const surfaceRaised = Color(0xFF132030);
  static const surfaceHighlight = Color(0xFF19273A);

  static const bottom = Color(0xFF0A1320);
  static const sheet = Color(0xFF131D2A);

  static const border = Color(0xFF1E3142);
  static const borderStrong = Color(0xFF284860);
  static const track = Color(0xFF1B2B3A);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF8BA3B8);
  static const textSubdued = Color(0xFF64748B);

  static const primary = Color(0xFF0284C7);
  static const accent = Color(0xFF38BDF8);
  static const emerald = Color(0xFF10B981);
  static const success = Color(0xFF4ADE80);
  static const amber = Color(0xFFFBBF24);
  static const quince = Color(0xFFF97316);
  static const purple = Color(0xFFA78BFA);
  static const danger = Color(0xFFF87171);

  /// Readable foreground for text or icons painted on a saturated [fill].
  ///
  /// White is the obvious choice on the darker fills, but the light ones
  /// (`danger`, `emerald`, `quince`) cannot carry white above 3:1. Badge labels
  /// run as small as 9px, so this returns whichever of [background] and white
  /// has the higher contrast against [fill] instead of assuming white works.
  static Color onFill(Color fill) {
    final luminance = fill.computeLuminance();
    final onWhite = (1.0 + 0.05) / (luminance + 0.05);
    final onDark = (luminance + 0.05) / (background.computeLuminance() + 0.05);
    return onDark >= onWhite ? background : Colors.white;
  }
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const sheet = 24.0;
  static const card = 16.0;
  static const pill = 8.0;
}

/// Shared text roles. The app intentionally uses a compact type ramp, but the
/// smallest role is kept at 11px for legibility on phone screens.
abstract final class AppText {
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const section = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 12,
    height: 1.35,
    color: AppColors.textMuted,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  static const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];
}

/// Applies Outfit to every style in [base].
///
/// `material_ui` declares its own [TextTheme] while GoogleFonts' text theme
/// helper is typed against `package:flutter/material.dart`, so the two cannot
/// be passed to each other. The individual styles are the shared [TextStyle]
/// type, so the font is applied per style; this matches the output of
/// `GoogleFonts.outfitTextTheme(base)` style for style.
TextTheme _outfitTextTheme(TextTheme base) {
  return TextTheme(
    displayLarge: GoogleFonts.outfit(textStyle: base.displayLarge),
    displayMedium: GoogleFonts.outfit(textStyle: base.displayMedium),
    displaySmall: GoogleFonts.outfit(textStyle: base.displaySmall),
    headlineLarge: GoogleFonts.outfit(textStyle: base.headlineLarge),
    headlineMedium: GoogleFonts.outfit(textStyle: base.headlineMedium),
    headlineSmall: GoogleFonts.outfit(textStyle: base.headlineSmall),
    titleLarge: GoogleFonts.outfit(textStyle: base.titleLarge),
    titleMedium: GoogleFonts.outfit(textStyle: base.titleMedium),
    titleSmall: GoogleFonts.outfit(textStyle: base.titleSmall),
    bodyLarge: GoogleFonts.outfit(textStyle: base.bodyLarge),
    bodyMedium: GoogleFonts.outfit(textStyle: base.bodyMedium),
    bodySmall: GoogleFonts.outfit(textStyle: base.bodySmall),
    labelLarge: GoogleFonts.outfit(textStyle: base.labelLarge),
    labelMedium: GoogleFonts.outfit(textStyle: base.labelMedium),
    labelSmall: GoogleFonts.outfit(textStyle: base.labelSmall),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final textTheme = _outfitTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onFill(AppColors.primary),
      secondary: AppColors.success,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    ),
    textTheme: textTheme,
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.track,
      circularTrackColor: AppColors.track,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onFill(AppColors.primary),
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(48, 44),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.textSecondary),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent.withValues(alpha: 0.35)
            : AppColors.border,
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 12),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceRaised,
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
