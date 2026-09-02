import 'package:flutter/material.dart';

/// Colour system.
///
/// Sampled from the reference design language rather than from the logo: a
/// periwinkle page (`#DAE3FB`), pure white cards floating on it, near-black for
/// anything that must be pressed, and a set of pastel washes — periwinkle,
/// orchid, amber, clay, mint — that sort a grid at a glance.
///
/// The logo's own hues survive as the *data* palette: the five bars under the
/// wordmark still drive the severity ramp, the map legend and every chart
/// series, so the brand mark and the data visualisation remain the same set of
/// colours even though the interface around them no longer is.
///
/// The `brandNavy` name is kept — it is referenced across the map, charts and
/// shadow recipes — but it now carries the near-black ink value rather than the
/// old navy.
abstract final class JanMaangColors {
  // ---------------------------------------------------------------------
  // Core
  // ---------------------------------------------------------------------

  /// Ink. Buttons, pill rows, the active navigation pill, primary actions.
  /// A very dark indigo rather than pure black, so it still belongs to the
  /// periwinkle family and does not read as a default Material black.
  static const brandNavy = Color(0xFF191A2E);

  /// The periwinkle that carries the page and the brand's ambient surfaces.
  static const brandPeriwinkle = Color(0xFF6B85F0);

  /// Orchid. Highlights, featured cards, the second categorical slot.
  static const brandOrchid = Color(0xFFC77BEE);

  /// Amber. Scheduled, pending, attention.
  static const brandAmber = Color(0xFFE5B54E);

  /// Clay. Activity, warmth, the fourth categorical slot.
  static const brandOrange = Color(0xFFE29448);

  /// Mint. Resolved work, verified impact.
  static const brandGreen = Color(0xFF2FAE6A);

  /// Kept for the data palette and the map legend.
  static const brandBlue = Color(0xFF4F68D8);
  static const brandRed = Color(0xFFD9534F);

  // ---------------------------------------------------------------------
  // Primary — Ink
  // ---------------------------------------------------------------------
  static const primary = brandNavy;
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2C2E4A);
  static const onPrimaryContainer = Color(0xFFDCE3FB);
  static const primaryFixed = Color(0xFFDCE3FB);
  static const primaryFixedDim = Color(0xFFB7C4F5);
  static const onPrimaryFixed = Color(0xFF1B1D33);
  static const onPrimaryFixedVariant = Color(0xFF3A3D5E);
  static const inversePrimary = Color(0xFFB7C4F5);

  // ---------------------------------------------------------------------
  // Secondary — Periwinkle
  // ---------------------------------------------------------------------
  static const secondary = Color(0xFF4F5FD8);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = brandPeriwinkle;
  static const onSecondaryContainer = Color(0xFFFFFFFF);
  static const secondaryFixed = Color(0xFFDCE3FB);
  static const secondaryFixedDim = Color(0xFFA0B8F9);
  static const onSecondaryFixed = Color(0xFF1E2A6B);
  static const onSecondaryFixedVariant = Color(0xFF3A4BB5);

  // ---------------------------------------------------------------------
  // Tertiary — Mint
  // ---------------------------------------------------------------------
  static const tertiary = Color(0xFF1E8F56);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = brandGreen;
  static const onTertiaryContainer = Color(0xFF0F4A28);
  static const tertiaryFixed = Color(0xFFCFEEDC);
  static const tertiaryFixedDim = Color(0xFF95DDB6);
  static const onTertiaryFixed = Color(0xFF0F4A28);
  static const onTertiaryFixedVariant = Color(0xFF1E8F56);

  // ---------------------------------------------------------------------
  // Error / warning
  // ---------------------------------------------------------------------
  static const error = Color(0xFFC93E3A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF8D7D7);
  static const onErrorContainer = Color(0xFF7A1F1D);

  static const warning = Color(0xFFB07A00);
  static const warningContainer = Color(0xFFF7E4B5);
  static const onWarningContainer = Color(0xFF5A3E00);

  // ---------------------------------------------------------------------
  // Surfaces
  //
  // `surface` is the *page*: periwinkle, not white. White is reserved for
  // cards, which is what makes them read as objects sitting on top of
  // something rather than as regions of one flat sheet.
  // ---------------------------------------------------------------------
  static const background = Color(0xFFDAE3FB);
  static const onBackground = Color(0xFF1B1D2E);
  static const surface = Color(0xFFDAE3FB);
  static const surfaceDim = Color(0xFFC6D2F3);
  static const surfaceBright = Color(0xFFFFFFFF);

  /// The card colour.
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F6FD);
  static const surfaceContainer = Color(0xFFE6EBFA);
  static const surfaceContainerHigh = Color(0xFFDCE3FB);
  static const surfaceContainerHighest = Color(0xFFCBD6F6);
  static const surfaceVariant = Color(0xFFE2E6F4);

  static const onSurface = Color(0xFF1B1D2E);
  static const onSurfaceVariant = Color(0xFF5A6076);
  static const inverseSurface = Color(0xFF191A2E);
  static const inverseOnSurface = Color(0xFFEDF0FB);
  static const surfaceTint = Color(0xFF6B85F0);

  static const outline = Color(0xFF8B90A5);
  static const outlineVariant = Color(0xFFE2E6F4);

  // ---------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------
  static const shadowAmbient = Color(0x0A191A2E);
  static const shadowModal = Color(0x14191A2E);
  static const micShadow = Color(0x26191A2E);
}

/// Dark counterparts.
///
/// The same figure-and-ground model inverts cleanly: the page is the darkest
/// value and cards sit one clear step above it.
abstract final class JanMaangDarkColors {
  static const primary = Color(0xFFB7C4F5);
  static const onPrimary = Color(0xFF1B1D33);
  static const primaryContainer = Color(0xFF3A3D5E);
  static const onPrimaryContainer = Color(0xFFDCE3FB);

  static const secondary = Color(0xFFA0B8F9);
  static const onSecondary = Color(0xFF1E2A6B);
  static const secondaryContainer = Color(0xFF3A4BB5);
  static const onSecondaryContainer = Color(0xFFDCE3FB);

  static const tertiary = Color(0xFF7FD9A4);
  static const onTertiary = Color(0xFF0F4A28);
  static const tertiaryContainer = Color(0xFF1E8F56);
  static const onTertiaryContainer = Color(0xFFCFEEDC);

  static const error = Color(0xFFFFB4AA);
  static const onError = Color(0xFF690003);
  static const errorContainer = Color(0xFF93110B);
  static const onErrorContainer = Color(0xFFF8D7D7);

  static const background = Color(0xFF0E0F1A);
  static const onBackground = Color(0xFFE4E7F2);
  static const surface = Color(0xFF0E0F1A);
  static const surfaceDim = Color(0xFF0E0F1A);
  static const surfaceBright = Color(0xFF2E3145);

  static const surfaceContainerLowest = Color(0xFF191B2A);
  static const surfaceContainerLow = Color(0xFF141625);
  static const surfaceContainer = Color(0xFF1F2233);
  static const surfaceContainerHigh = Color(0xFF292D42);
  static const surfaceContainerHighest = Color(0xFF343852);
  static const surfaceVariant = Color(0xFF3F4459);

  static const onSurface = Color(0xFFE4E7F2);
  static const onSurfaceVariant = Color(0xFFA8AEC4);
  static const inverseSurface = Color(0xFFE4E7F2);
  static const inverseOnSurface = Color(0xFF191A2E);

  static const outline = Color(0xFF7E849B);
  static const outlineVariant = Color(0xFF2E3245);

  static const warning = Color(0xFFE5B54E);
  static const warningContainer = Color(0xFF5A3E00);
  static const onWarningContainer = Color(0xFFF7E4B5);
}

/// The tile tints.
///
/// Six pastel washes, each with a foreground dark enough to clear 4.5:1. A
/// grid of these reads as a set of categories at a glance — but every tile
/// that uses one also carries its own icon and its own words, so the sorting
/// survives greyscale and colour-blindness.
///
/// Every wash is deliberately kept clear of the page colour (`#DAE3FB`). A
/// tint within a few values of the background is not a subtle tile, it is an
/// invisible one — which is exactly what happened to the first two cells of
/// every grid before these values were pulled apart.
enum JmTint {
  /// Periwinkle. The default, and the one the brand leans on.
  navy(Color(0xFFC3D3F8), Color(0xFF1E2A6B), JanMaangColors.brandPeriwinkle),

  /// Orchid. Featured, highlighted, special.
  orchid(Color(0xFFE9CEF9), Color(0xFF4A1D6B), JanMaangColors.brandOrchid),

  /// Amber. Scheduled, pending, waiting.
  amber(Color(0xFFF7E4B5), Color(0xFF5A3E00), JanMaangColors.brandAmber),

  /// Blue. Informational, active.
  blue(Color(0xFFCCE6F7), Color(0xFF10456B), JanMaangColors.brandBlue),

  /// Clay. Activity, warmth.
  clay(Color(0xFFF8DCC2), Color(0xFF6B3A08), JanMaangColors.brandOrange),

  /// Mint. Resolved, funded, verified.
  green(Color(0xFFCFEEDC), Color(0xFF0F4A28), JanMaangColors.brandGreen);

  const JmTint(this.light, this.onLight, this.hue);

  /// The wash, on a light page.
  final Color light;

  /// Text and glyphs on that wash.
  final Color onLight;

  /// The saturated hue the wash is derived from. Used for the small accents
  /// inside the tile — an icon well, a progress arc.
  final Color hue;

  Color background(Brightness b) =>
      b == Brightness.light ? light : hue.withValues(alpha: 0.18);

  Color foreground(Brightness b) => b == Brightness.light
      ? onLight
      : Color.lerp(hue, const Color(0xFFFFFFFF), 0.66)!;

  /// The icon well inside the tile — a step more saturated than the wash.
  Color well(Brightness b) => b == Brightness.light
      ? hue.withValues(alpha: 0.20)
      : hue.withValues(alpha: 0.30);
}

/// Semantic status pairs.
///
/// Every status in the product resolves to one of these six. The pattern is
/// always a light tint behind a dark, legible foreground — never a saturated
/// fill with white text at small sizes — so a badge stays readable at 12px and
/// keeps its contrast when several sit in a row.
///
/// Colour is never the only signal: each of these is paired with a label and
/// an icon wherever it appears.
abstract final class JmSemantic {
  /// Resolved, verified, funded.
  static const success = Color(0xFF1E8F56);
  static const successTint = Color(0xFFCFEEDC);
  static const onSuccessTint = Color(0xFF0F4A28);

  /// Pending, awaiting review, in progress.
  static const warning = Color(0xFFB07A00);
  static const warningTint = Color(0xFFF7E4B5);
  static const onWarningTint = Color(0xFF5A3E00);

  /// Failed, critical, urgent.
  static const critical = Color(0xFFC93E3A);
  static const criticalTint = Color(0xFFF8D7D7);
  static const onCriticalTint = Color(0xFF7A1F1D);

  /// Informational, active, in the system.
  static const info = Color(0xFF4F5FD8);
  static const infoTint = Color(0xFFDCE3FB);
  static const onInfoTint = Color(0xFF1E2A6B);

  /// Ranks, milestones, achievements. Used sparingly.
  static const gold = Color(0xFF9A7400);
  static const goldTint = Color(0xFFF7E9C4);
  static const onGoldTint = Color(0xFF5A3E00);

  /// Neutral / archived / not applicable.
  static const neutral = Color(0xFF5A6076);
  static const neutralTint = Color(0xFFECEEF6);
  static const onNeutralTint = Color(0xFF2B2E3D);
}

/// Chart and data-visualisation palette.
///
/// A fixed order, so the same series is the same colour on every screen and
/// nothing is ever picked at random.
///
/// Categorical hues are distinguishable in the common forms of colour-vision
/// deficiency by luminance as well as hue, and every chart in the product also
/// labels its series directly rather than relying on a legend swatch alone.
abstract final class JmChart {
  /// Primary series — the figure the screen is actually about.
  static const primary = JanMaangColors.brandPeriwinkle;

  /// Secondary series — the comparison, usually the previous period.
  static const secondary = JanMaangColors.brandGreen;

  /// Tertiary series.
  static const tertiary = JanMaangColors.brandOrchid;

  /// Highlight — the bar or slice being called out.
  static const highlight = JanMaangColors.brandOrange;

  /// Special highlight — records, peaks, achievements.
  static const special = JanMaangColors.brandAmber;

  /// Critical — the series that represents a problem.
  static const critical = JanMaangColors.brandRed;

  /// Ordered categorical ramp. Index into this rather than choosing a colour.
  static const series = <Color>[
    primary,
    secondary,
    tertiary,
    highlight,
    special,
    critical,
  ];

  /// Colour for series [index], wrapping if a chart has more than six.
  static Color at(int index) => series[index % series.length];

  /// Axis lines, gridlines and tick labels. Deliberately quiet — the data
  /// should be the loudest thing in the frame.
  static const grid = Color(0xFFE2E6F4);
  static const gridDark = Color(0xFF2E3245);
  static const axisLabel = Color(0xFF5A6076);
  static const axisLabelDark = Color(0xFFA8AEC4);

  /// Fill for a bar or region whose value is incomplete — the 2025 partial
  /// year, for one. Rendered as a desaturated version of its series colour so
  /// it cannot be misread as a real decline.
  static Color partial(Color base) =>
      Color.lerp(base, const Color(0xFFFFFFFF), 0.55)!;
}

/// How many reports at one place, and how loudly the map should say so.
///
/// The spec is explicit that colour alone must not carry this — every tier
/// also changes pin size, ring weight and the count badge, so the ranking
/// survives greyscale and colour-blindness.
enum DensityTier {
  low('Low', 1, JanMaangColors.brandGreen, Color(0xFFFFFFFF), 34),
  moderate('Moderate', 5, JanMaangColors.brandAmber, Color(0xFF5A3E00), 42),
  high('High', 20, JanMaangColors.brandOrange, Color(0xFF6B3A08), 52),
  critical('Critical', 50, JanMaangColors.brandRed, Color(0xFFFFFFFF), 64);

  const DensityTier(this.label, this.minReports, this.color, this.onColor,
      this.markerSize);

  final String label;

  /// Lower bound of the tier, inclusive.
  final int minReports;
  final Color color;
  final Color onColor;

  /// Diameter in logical pixels, so density reads without relying on hue.
  final double markerSize;

  /// Ring thickness — a second non-colour cue that grows with the tier.
  double get ringWidth => switch (this) {
        DensityTier.low => 2,
        DensityTier.moderate => 2.5,
        DensityTier.high => 3,
        DensityTier.critical => 4,
      };

  /// Only the top tier pulses. Animating every marker makes the map noisy,
  /// which the brief calls out explicitly.
  bool get pulses => this == DensityTier.critical;

  static DensityTier forReports(int reports) {
    if (reports >= DensityTier.critical.minReports) return DensityTier.critical;
    if (reports >= DensityTier.high.minReports) return DensityTier.high;
    if (reports >= DensityTier.moderate.minReports) return DensityTier.moderate;
    return DensityTier.low;
  }
}
