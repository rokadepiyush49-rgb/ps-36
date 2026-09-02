import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_spacing.dart';
import 'janmaang_colors.dart';
import 'janmaang_typography.dart';

/// Builds the Material 3 themes from the JanMaang tokens.
///
/// Hierarchy comes from tonal layers, 1px hairlines and one very soft
/// navy-tinted shadow — never from Material's elevation overlays, which are
/// switched off throughout. Every component that can be themed centrally is
/// themed here, so a screen should almost never need to set a colour or a
/// radius by hand.
abstract final class AppTheme {
  static ThemeData get light => _build(_lightScheme, Brightness.light);
  static ThemeData get dark => _build(_darkScheme, Brightness.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: JanMaangColors.primary,
    onPrimary: JanMaangColors.onPrimary,
    primaryContainer: JanMaangColors.primaryContainer,
    onPrimaryContainer: JanMaangColors.onPrimaryContainer,
    primaryFixed: JanMaangColors.primaryFixed,
    primaryFixedDim: JanMaangColors.primaryFixedDim,
    onPrimaryFixed: JanMaangColors.onPrimaryFixed,
    onPrimaryFixedVariant: JanMaangColors.onPrimaryFixedVariant,
    secondary: JanMaangColors.secondary,
    onSecondary: JanMaangColors.onSecondary,
    secondaryContainer: JanMaangColors.secondaryContainer,
    onSecondaryContainer: JanMaangColors.onSecondaryContainer,
    secondaryFixed: JanMaangColors.secondaryFixed,
    secondaryFixedDim: JanMaangColors.secondaryFixedDim,
    onSecondaryFixed: JanMaangColors.onSecondaryFixed,
    onSecondaryFixedVariant: JanMaangColors.onSecondaryFixedVariant,
    tertiary: JanMaangColors.tertiary,
    onTertiary: JanMaangColors.onTertiary,
    tertiaryContainer: JanMaangColors.tertiaryContainer,
    onTertiaryContainer: JanMaangColors.onTertiaryContainer,
    tertiaryFixed: JanMaangColors.tertiaryFixed,
    tertiaryFixedDim: JanMaangColors.tertiaryFixedDim,
    onTertiaryFixed: JanMaangColors.onTertiaryFixed,
    onTertiaryFixedVariant: JanMaangColors.onTertiaryFixedVariant,
    error: JanMaangColors.error,
    onError: JanMaangColors.onError,
    errorContainer: JanMaangColors.errorContainer,
    onErrorContainer: JanMaangColors.onErrorContainer,
    surface: JanMaangColors.surface,
    onSurface: JanMaangColors.onSurface,
    surfaceDim: JanMaangColors.surfaceDim,
    surfaceBright: JanMaangColors.surfaceBright,
    surfaceContainerLowest: JanMaangColors.surfaceContainerLowest,
    surfaceContainerLow: JanMaangColors.surfaceContainerLow,
    surfaceContainer: JanMaangColors.surfaceContainer,
    surfaceContainerHigh: JanMaangColors.surfaceContainerHigh,
    surfaceContainerHighest: JanMaangColors.surfaceContainerHighest,
    onSurfaceVariant: JanMaangColors.onSurfaceVariant,
    inverseSurface: JanMaangColors.inverseSurface,
    onInverseSurface: JanMaangColors.inverseOnSurface,
    inversePrimary: JanMaangColors.inversePrimary,
    outline: JanMaangColors.outline,
    outlineVariant: JanMaangColors.outlineVariant,
    surfaceTint: JanMaangColors.surfaceTint,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: JanMaangDarkColors.primary,
    onPrimary: JanMaangDarkColors.onPrimary,
    primaryContainer: JanMaangDarkColors.primaryContainer,
    onPrimaryContainer: JanMaangDarkColors.onPrimaryContainer,
    primaryFixed: JanMaangColors.primaryFixed,
    primaryFixedDim: JanMaangColors.primaryFixedDim,
    onPrimaryFixed: JanMaangColors.onPrimaryFixed,
    onPrimaryFixedVariant: JanMaangColors.onPrimaryFixedVariant,
    secondary: JanMaangDarkColors.secondary,
    onSecondary: JanMaangDarkColors.onSecondary,
    secondaryContainer: JanMaangDarkColors.secondaryContainer,
    onSecondaryContainer: JanMaangDarkColors.onSecondaryContainer,
    secondaryFixed: JanMaangColors.secondaryFixed,
    secondaryFixedDim: JanMaangColors.secondaryFixedDim,
    onSecondaryFixed: JanMaangColors.onSecondaryFixed,
    onSecondaryFixedVariant: JanMaangColors.onSecondaryFixedVariant,
    tertiary: JanMaangDarkColors.tertiary,
    onTertiary: JanMaangDarkColors.onTertiary,
    tertiaryContainer: JanMaangDarkColors.tertiaryContainer,
    onTertiaryContainer: JanMaangDarkColors.onTertiaryContainer,
    tertiaryFixed: JanMaangColors.tertiaryFixed,
    tertiaryFixedDim: JanMaangColors.tertiaryFixedDim,
    onTertiaryFixed: JanMaangColors.onTertiaryFixed,
    onTertiaryFixedVariant: JanMaangColors.onTertiaryFixedVariant,
    error: JanMaangDarkColors.error,
    onError: JanMaangDarkColors.onError,
    errorContainer: JanMaangDarkColors.errorContainer,
    onErrorContainer: JanMaangDarkColors.onErrorContainer,
    surface: JanMaangDarkColors.surface,
    onSurface: JanMaangDarkColors.onSurface,
    surfaceDim: JanMaangDarkColors.surfaceDim,
    surfaceBright: JanMaangDarkColors.surfaceBright,
    surfaceContainerLowest: JanMaangDarkColors.surfaceContainerLowest,
    surfaceContainerLow: JanMaangDarkColors.surfaceContainerLow,
    surfaceContainer: JanMaangDarkColors.surfaceContainer,
    surfaceContainerHigh: JanMaangDarkColors.surfaceContainerHigh,
    surfaceContainerHighest: JanMaangDarkColors.surfaceContainerHighest,
    onSurfaceVariant: JanMaangDarkColors.onSurfaceVariant,
    inverseSurface: JanMaangDarkColors.inverseSurface,
    onInverseSurface: JanMaangDarkColors.inverseOnSurface,
    inversePrimary: JanMaangColors.primary,
    outline: JanMaangDarkColors.outline,
    outlineVariant: JanMaangDarkColors.outlineVariant,
    surfaceTint: JanMaangColors.surfaceTint,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final textTheme =
        JanMaangTypography.textTheme(scheme.onSurface, scheme.onSurfaceVariant);
    final isLight = brightness == Brightness.light;

    // One shape per role, resolved once so no component can drift.
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Corners.base),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Corners.lg),
    );
    final containerShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Corners.xl),
    );
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Corners.pill),
    );

    OutlineInputBorder field(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.base),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      fontFamily: JanMaangTypography.bodyFamily,
      // The system defines depth through tonal layers, not elevation overlays.
      applyElevationOverlayColor: false,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      // A single icon weight and size across the app, so a Material icon next
      // to a custom one reads as the same family.
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
      primaryIconTheme: IconThemeData(color: scheme.primary, size: 22),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle:
            JanMaangTypography.headlineSm.copyWith(color: scheme.primary),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        actionsIconTheme:
            IconThemeData(color: scheme.onSurfaceVariant, size: 22),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scheme.surface,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scheme.surface,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),

      // Cards are pure white on the tinted page and carry no hairline — the
      // tint difference is the separation. The soft shadow is applied by
      // JmCard rather than here, so a card nested inside another card can opt
      // out of it and stay flat.
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ---- Primary action: navy fill, white label -----------------------
      // Hover lifts it a little, press compresses the overlay. Disabled keeps
      // enough contrast to stay readable rather than dissolving into the card.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.primary.withValues(alpha: 0.38);
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onPrimary.withValues(alpha: 0.85);
            }
            return scheme.onPrimary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.10);
            }
            if (states.contains(WidgetState.focused)) {
              return Colors.white.withValues(alpha: 0.14);
            }
            return null;
          }),
          elevation: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered) &&
                      !states.contains(WidgetState.disabled)
                  ? 2
                  : 0),
          shadowColor: WidgetStatePropertyAll<Color>(
            JanMaangColors.brandNavy.withValues(alpha: 0.35),
          ),
          minimumSize:
              const WidgetStatePropertyAll<Size>(Size.fromHeight(Hit.control)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            JanMaangTypography.titleLg,
          ),
          iconSize: const WidgetStatePropertyAll<double>(20),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
        ),
      ),

      // ---- Secondary action: light surface, navy label, hairline --------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return scheme.surfaceContainerLow;
            }
            return scheme.surfaceContainerLowest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurfaceVariant.withValues(alpha: 0.5);
            }
            return scheme.primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? scheme.primary.withValues(alpha: 0.10)
                  : null),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: scheme.outlineVariant);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return BorderSide(color: scheme.primary, width: 1.5);
            }
            return BorderSide(color: scheme.outline);
          }),
          minimumSize:
              const WidgetStatePropertyAll<Size>(Size.fromHeight(Hit.min)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle>(
            JanMaangTypography.withWeight(
              JanMaangTypography.bodySm,
              FontWeight.w600,
            ),
          ),
          iconSize: const WidgetStatePropertyAll<double>(20),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : scheme.secondary),
          overlayColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? scheme.secondary.withValues(alpha: 0.12)
                  : states.contains(WidgetState.hovered)
                      ? scheme.secondary.withValues(alpha: 0.07)
                      : null),
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, Hit.min)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle>(
            JanMaangTypography.withWeight(
              JanMaangTypography.bodySm,
              FontWeight.w600,
            ),
          ),
          iconSize: const WidgetStatePropertyAll<double>(18),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size.square(Hit.min)),
          overlayColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? scheme.primary.withValues(alpha: 0.12)
                  : states.contains(WidgetState.hovered)
                      ? scheme.primary.withValues(alpha: 0.07)
                      : null),
          shape: WidgetStatePropertyAll<OutlinedBorder>(pillShape),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: cardShape,
      ),

      // ---- Fields: 12px radius, 2px navy focus ring ---------------------
      // The focus ring is the brand navy rather than Material's default,
      // because the field is the most common place a citizen sees the app
      // respond to them.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.md,
        ),
        hintStyle: JanMaangTypography.bodyMd.copyWith(color: scheme.outline),
        labelStyle:
            JanMaangTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle:
            JanMaangTypography.labelMd.copyWith(color: scheme.primary),
        helperStyle:
            JanMaangTypography.bodySm.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: JanMaangTypography.bodySm.copyWith(color: scheme.error),
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? scheme.primary
                : scheme.onSurfaceVariant),
        suffixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? scheme.primary
                : scheme.onSurfaceVariant),
        border: field(scheme.outlineVariant),
        enabledBorder: field(scheme.outlineVariant),
        focusedBorder: field(scheme.primary, 2),
        disabledBorder: field(scheme.outlineVariant.withValues(alpha: 0.6)),
        errorBorder: field(scheme.error),
        focusedErrorBorder: field(scheme.error, 2),
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor:
            WidgetStatePropertyAll<Color>(scheme.surfaceContainerLowest),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        elevation: const WidgetStatePropertyAll<double>(0),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: scheme.outlineVariant),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: Insets.md),
        ),
        hintStyle: WidgetStatePropertyAll<TextStyle>(
          JanMaangTypography.bodyMd.copyWith(color: scheme.outline),
        ),
      ),

      // ---- Chips and filters: pill, tinted when selected ----------------
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primaryFixed,
        checkmarkColor: scheme.onPrimaryFixed,
        disabledColor: scheme.surfaceContainerHigh,
        labelStyle: JanMaangTypography.withWeight(
          JanMaangTypography.bodySm,
          FontWeight.w600,
        ).copyWith(color: scheme.onSurfaceVariant),
        secondaryLabelStyle: JanMaangTypography.withWeight(
          JanMaangTypography.bodySm,
          FontWeight.w600,
        ).copyWith(color: scheme.onPrimaryFixed),
        side: BorderSide(color: scheme.outlineVariant),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.sm + 2,
        ),
        shape: pillShape,
      ),

      // ---- Tabs: a pill indicator rather than an underline --------------
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: scheme.onPrimaryFixed,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: JanMaangTypography.withWeight(
          JanMaangTypography.bodySm,
          FontWeight.w700,
        ),
        unselectedLabelStyle: JanMaangTypography.withWeight(
          JanMaangTypography.bodySm,
          FontWeight.w600,
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.pressed)
                ? scheme.primary.withValues(alpha: 0.08)
                : null),
        indicator: BoxDecoration(
          color: scheme.primaryFixed,
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryFixed,
        indicatorShape: pillShape,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryFixed
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? JanMaangTypography.labelMd.copyWith(color: scheme.onPrimaryFixed)
              : JanMaangTypography.labelMd
                  .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryFixed,
        indicatorShape: pillShape,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryFixed, size: 24),
        unselectedIconTheme:
            IconThemeData(color: scheme.onSurfaceVariant, size: 24),
        selectedLabelTextStyle:
            JanMaangTypography.labelMd.copyWith(color: scheme.primary),
        unselectedLabelTextStyle:
            JanMaangTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 8,
        strokeCap: StrokeCap.round,
        strokeWidth: 3,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            JanMaangTypography.bodySm.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(Insets.md),
        elevation: 0,
        shape: cardShape,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: JanMaangColors.brandNavy.withValues(alpha: 0.32),
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.xl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle:
            JanMaangTypography.headlineSm.copyWith(color: scheme.onSurface),
        contentTextStyle:
            JanMaangTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
        shape: containerShape,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: JanMaangTypography.bodyMd.copyWith(color: scheme.onSurface),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
        textStyle:
            JanMaangTypography.bodySm.copyWith(color: scheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.sm + 2,
          vertical: Insets.sm - 2,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.surfaceContainerLowest,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outlineVariant,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm - 2),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 6,
      ),

      listTileTheme: ListTileThemeData(
        titleTextStyle:
            JanMaangTypography.bodyMd.copyWith(color: scheme.onSurface),
        subtitleTextStyle:
            JanMaangTypography.bodySm.copyWith(color: scheme.onSurfaceVariant),
        iconColor: scheme.onSurfaceVariant,
        selectedColor: scheme.primary,
        selectedTileColor: scheme.primaryFixed,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.xs,
        ),
        minVerticalPadding: Insets.sm,
        shape: cardShape,
      ),

      expansionTileTheme: ExpansionTileThemeData(
        iconColor: scheme.primary,
        collapsedIconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        shape: cardShape,
        collapsedShape: cardShape,
      ),
    );
  }
}
