import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/theme/janmaang_colors.dart';

void main() {
  group('DensityTier.forReports', () {
    test('maps report counts onto the four tiers', () {
      expect(DensityTier.forReports(1), DensityTier.low);
      expect(DensityTier.forReports(4), DensityTier.low);
      expect(DensityTier.forReports(5), DensityTier.moderate);
      expect(DensityTier.forReports(19), DensityTier.moderate);
      expect(DensityTier.forReports(20), DensityTier.high);
      expect(DensityTier.forReports(49), DensityTier.high);
      expect(DensityTier.forReports(50), DensityTier.critical);
      expect(DensityTier.forReports(500), DensityTier.critical);
    });

    test('a place with no reports still renders as low rather than crashing',
        () {
      expect(DensityTier.forReports(0), DensityTier.low);
    });
  });

  group('non-colour cues', () {
    test('marker size grows strictly with the tier', () {
      final sizes = DensityTier.values.map((t) => t.markerSize).toList();
      for (var i = 1; i < sizes.length; i++) {
        expect(sizes[i], greaterThan(sizes[i - 1]),
            reason: 'tier ${DensityTier.values[i]} must be larger');
      }
    });

    test('ring weight grows strictly with the tier', () {
      final rings = DensityTier.values.map((t) => t.ringWidth).toList();
      for (var i = 1; i < rings.length; i++) {
        expect(rings[i], greaterThan(rings[i - 1]));
      }
    });

    test('only the critical tier pulses, so the map stays readable', () {
      expect(
        DensityTier.values.where((t) => t.pulses).toList(),
        <DensityTier>[DensityTier.critical],
      );
    });

    test('every tier carries a distinct colour from the brand spectrum', () {
      final colours = DensityTier.values.map((t) => t.color).toSet();
      expect(colours.length, DensityTier.values.length);
      expect(colours, contains(JanMaangColors.brandGreen));
      expect(colours, contains(JanMaangColors.brandRed));
    });
  });
}
