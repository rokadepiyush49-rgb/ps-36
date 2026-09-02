import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';

/// Explains the density ramp.
///
/// A ranking the citizen cannot decode is not transparency, so the legend
/// states the report thresholds outright rather than showing colour swatches
/// alone — and it names the non-colour cues too, since colour is never the only
/// channel carrying the ranking.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 232,
      padding: const EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(Corners.lg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: JanMaangColors.shadowModal,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'REPORTS AT ONE PLACE',
            style: JanMaangTypography.labelMd
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.sm),
          for (final tier in DensityTier.values) ...<Widget>[
            _LegendRow(tier: tier),
            if (tier != DensityTier.values.last)
              const SizedBox(height: Insets.sm),
          ],
          const SizedBox(height: Insets.md),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: Insets.sm),
          Text(
            'Pin size, ring weight and the count badge move with the tier, so '
            'the ranking reads without relying on colour.',
            style: JanMaangTypography.bodySm.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.tier});

  final DensityTier tier;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final range = switch (tier) {
      DensityTier.low => '1–4 reports',
      DensityTier.moderate => '5–19 reports',
      DensityTier.high => '20–49 reports',
      DensityTier.critical => '50+ reports',
    };

    // Scaled down proportionally so the legend mirrors the real size ramp.
    final dot = 10 + tier.index * 3.0;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 24,
          child: Center(
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: tier.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: tier.ringWidth / 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: Insets.sm),
        Expanded(
          child: Text(
            tier.label,
            style: JanMaangTypography.bodySm.copyWith(color: scheme.onSurface),
          ),
        ),
        Text(
          range,
          style: JanMaangTypography.labelMd
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
