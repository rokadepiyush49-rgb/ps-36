import 'package:flutter/material.dart';

/// Type scale transcribed from the Stitch design system.
///
/// Dual-font strategy: **DM Sans** carries display and headline levels for
/// brand character, **Inter** is the workhorse for titles, body, labels and
/// every number in a table.
abstract final class JanMaangTypography {
  static const displayFamily = 'DMSans';
  static const bodyFamily = 'Inter';

  static List<FontVariation> _wght(double weight) =>
      <FontVariation>[FontVariation('wght', weight)];

  // ---- Display ----
  static const displayLg = TextStyle(
    fontFamily: displayFamily,
    fontSize: 48,
    height: 56 / 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 48,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
  );

  /// The mobile display size — the one the citizen screens actually use.
  static const displayLgMobile = TextStyle(
    fontFamily: displayFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 32,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
  );

  // ---- Headline ----
  static const headlineMd = TextStyle(
    fontFamily: displayFamily,
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  static const headlineSm = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  // ---- Title ----
  static const titleLg = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  // ---- Body ----
  static const bodyLg = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  static const bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  static const bodySm = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  // ---- Label ----
  static const labelMd = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05 * 12,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  /// The navigation bar label. A step below labelMd so five destinations fit
  /// across a small phone without truncating, with the letter-spacing kept so
  /// it still reads as a label rather than shrunken body copy.
  static const navLabel = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  /// Timestamps, source attributions, provenance lines, helper text under a
  /// field. The smallest type in the product — never used for anything a
  /// citizen has to act on.
  static const caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  /// Numerals in tables, budgets and metrics. The design system requires
  /// tabular figures so columns of numbers align across rows.
  static const tabularNums = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    fontVariations: <FontVariation>[FontVariation('wght', 500)],
  );

  /// A big tabular figure — the "41" / "4,281" stat tiles on Home and the
  /// cluster screen use headline-md sizing with tabular figures on.
  static const statNumber = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w700,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
  );

  /// Applies a weight to a variable-font style so the `wght` axis and the
  /// [FontWeight] stay in agreement.
  static TextStyle withWeight(TextStyle base, FontWeight weight) => base.copyWith(
        fontWeight: weight,
        fontVariations: _wght(weight.value.toDouble()),
      );

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) => TextTheme(
        displayLarge: displayLg.copyWith(color: onSurface),
        displayMedium: displayLgMobile.copyWith(color: onSurface),
        displaySmall: headlineMd.copyWith(color: onSurface),
        headlineLarge: headlineMd.copyWith(color: onSurface),
        headlineMedium: headlineMd.copyWith(color: onSurface),
        headlineSmall: headlineSm.copyWith(color: onSurface),
        titleLarge: titleLg.copyWith(color: onSurface),
        titleMedium: titleLg.copyWith(color: onSurface),
        titleSmall: bodySm.copyWith(color: onSurface),
        bodyLarge: bodyLg.copyWith(color: onSurface),
        bodyMedium: bodyMd.copyWith(color: onSurface),
        bodySmall: bodySm.copyWith(color: onSurfaceVariant),
        labelLarge: labelMd.copyWith(color: onSurface),
        labelMedium: labelMd.copyWith(color: onSurfaceVariant),
        labelSmall: navLabel.copyWith(color: onSurfaceVariant),
      );
}
