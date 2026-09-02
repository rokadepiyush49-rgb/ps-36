import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_typography.dart';

/// "Where exactly is the problem located?" — the gradient action card with the
/// Select-on-Map and Use-My-Location pair.
class LocationActionCard extends StatelessWidget {
  const LocationActionCard({
    super.key,
    required this.hasLocation,
    required this.locationLabel,
    required this.onUseMyLocation,
    required this.onSelectOnMap,
  });

  final bool hasLocation;
  final String locationLabel;
  final VoidCallback onUseMyLocation;
  final VoidCallback onSelectOnMap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.surfaceContainer,
            scheme.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(Corners.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                hasLocation ? Icons.check_circle : Icons.explore_outlined,
                size: 20,
                color: hasLocation
                    ? scheme.onTertiaryContainer
                    : scheme.secondary,
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Text(
                  hasLocation
                      ? 'Location pinned'
                      : 'Where exactly is the problem located?',
                  style: JanMaangTypography.titleLg
                      .copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.xs),
          Text(
            hasLocation
                ? (locationLabel.isEmpty
                    ? 'Officials will be routed to this spot.'
                    : '$locationLabel — officials will be routed here.')
                : 'Pinpoint the location to help officials respond faster.',
            style: JanMaangTypography.bodyMd
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSelectOnMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Select on Map'),
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onUseMyLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Use My Location'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    textStyle: JanMaangTypography.labelMd,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
