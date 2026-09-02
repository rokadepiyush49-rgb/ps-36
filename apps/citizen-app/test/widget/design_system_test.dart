import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/theme/app_theme.dart';
import 'package:janmaang/core/theme/janmaang_colors.dart';
import 'package:janmaang/core/theme/janmaang_typography.dart';

void main() {
  group('theme carries the Stitch tokens', () {
    test('light scheme uses the design system colour roles', () {
      final scheme = AppTheme.light.colorScheme;
      expect(scheme.primary, JanMaangColors.primary);
      expect(scheme.secondary, JanMaangColors.secondary);
      expect(scheme.tertiaryFixed, JanMaangColors.tertiaryFixed);
      expect(scheme.surface, JanMaangColors.surface);
      expect(scheme.outlineVariant, JanMaangColors.outlineVariant);
    });

    test('depth comes from hairlines, not elevation overlays', () {
      final theme = AppTheme.light;
      expect(theme.applyElevationOverlayColor, isFalse);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    });

    test('both brightnesses are fully defined', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.colorScheme.surface, isNot(JanMaangColors.surface));
    });
  });

  group('typography', () {
    test('display and headline levels use DM Sans, body uses Inter', () {
      expect(JanMaangTypography.displayLgMobile.fontFamily, 'DMSans');
      expect(JanMaangTypography.headlineSm.fontFamily, 'DMSans');
      expect(JanMaangTypography.bodyMd.fontFamily, 'Inter');
      expect(JanMaangTypography.labelMd.fontFamily, 'Inter');
    });

    test('sizes and leading match the design tokens', () {
      expect(JanMaangTypography.displayLgMobile.fontSize, 32);
      expect(JanMaangTypography.headlineMd.fontSize, 30);
      expect(JanMaangTypography.bodyMd.fontSize, 16);
      expect(JanMaangTypography.labelMd.fontSize, 12);
      expect(JanMaangTypography.bodyMd.height, 24 / 16);
    });

    test('numeric styles enable tabular figures', () {
      expect(
        JanMaangTypography.tabularNums.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        JanMaangTypography.statNumber.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });
  });
}
