import 'package:flutter/widgets.dart';

/// Spacing and shape tokens.
///
/// Everything is a multiple of the 4px baseline grid that gives the interface
/// its vertical rhythm.
abstract final class Insets {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 48;

  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 32;
  static const double containerMax = 1280;

  /// Clearance a scrolling tab body must leave under its last element so the
  /// floating navigation bar never covers content. Bar height + its margin +
  /// the raised Report button's overhang.
  static const double navClearance = 116;
}

/// Shape language.
///
/// Soft and generous: white cards float on a tinted page, and the radius is
/// what makes them read as separate objects rather than panels welded to the
/// background. Pills are used liberally — on chips, filters, list rows and the
/// navigation indicator — because a fully rounded row is the reference
/// language's signature and it costs nothing in legibility.
abstract final class Corners {
  /// Small tags, inline pips, icon wells.
  static const double sm = 10;

  /// Buttons, input fields, small controls.
  static const double base = 16;

  /// The standard card.
  static const double lg = 28;

  /// Sheets, modals, the floating navigation bar, hero containers.
  static const double xl = 34;

  /// Chips, filters, status badges, list rows, the navigation indicator.
  static const double pill = 999;
}

/// Elevation recipe.
///
/// The tinted page background does most of the separating, so shadows here are
/// deliberately faint — wide, low-opacity and tinted with the brand navy, never
/// a grey drop shadow. Three levels only, so two adjacent surfaces are never
/// ambiguous.
abstract final class Shadows {
  /// Resting card on the tinted page.
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F191A2E),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x0A191A2E),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  /// Hovered or emphasised card, the raised Report action, dark pill rows.
  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F191A2E),
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -10,
    ),
  ];

  /// The floating navigation bar, popovers, map callouts.
  static const List<BoxShadow> level3 = <BoxShadow>[
    BoxShadow(
      color: Color(0x24191A2E),
      offset: Offset(0, 14),
      blurRadius: 40,
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Color(0x0F191A2E),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];
}

/// Minimum interactive sizes. Below these a control fails the accessibility
/// review, whatever it looks like.
abstract final class Hit {
  /// Absolute floor for any tappable target.
  static const double min = 48;

  /// Standard control height — buttons, inputs, filter chips.
  static const double control = 54;

  /// Dense controls where the standard height would crowd the layout.
  static const double controlDense = 44;

  /// The circular icon buttons in headers and app bars.
  static const double circleButton = 44;
}

/// Layout breakpoint. Below this the designs collapse the side nav into the
/// bottom navigation bar and stack the bento grid into a single column.
abstract final class Breakpoints {
  static const double medium = 768;
  static const double expanded = 1024;
}
