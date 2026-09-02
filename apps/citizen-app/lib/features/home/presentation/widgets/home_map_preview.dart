import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../../map/domain/map_issue.dart';
import '../../../map/presentation/map_controller.dart';
import '../../../map/presentation/widgets/jm_issue_marker.dart';

/// The "Live Resource Map" card on Home.
///
/// A real OpenStreetMap view rather than a picture of one, but deliberately
/// inert: gestures are disabled and the whole card is a single tap target that
/// opens the full map. A half-interactive map inside a scrolling list fights
/// the scroll and satisfies nobody.
class HomeMapPreview extends ConsumerWidget {
  const HomeMapPreview({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final issues = ref.watch(filteredIssuesProvider);

    // Show the heaviest sites — the preview should communicate where the
    // pressure is, not every pin in the district.
    final shown = (<MapIssue>[...issues]
          ..sort((a, b) => b.reportCount.compareTo(a.reportCount)))
        .take(6)
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(Corners.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                initialCenter: MapViewport.initial.centre,
                initialZoom: 11.5,
                // Inert: the card is one tap target.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'in.janmaang.app',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(
                  markers: <Marker>[
                    for (final issue in shown)
                      Marker(
                        point: issue.position,
                        width: issue.displayTier.markerSize + 26,
                        height: issue.displayTier.markerSize + 26,
                        alignment: Alignment.center,
                        child: IgnorePointer(
                          child: JmIssueMarker(issue: issue, selected: false),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Full-card tap target sitting above the map.
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),

            Positioned(
              left: Insets.md,
              right: Insets.md,
              bottom: Insets.md,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.md,
                    vertical: Insets.sm,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.93),
                    borderRadius: BorderRadius.circular(Corners.base),
                    border: Border.all(color: scheme.outlineVariant),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: JanMaangColors.shadowAmbient,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.public, size: 15, color: scheme.primary),
                      const SizedBox(width: Insets.sm),
                      Expanded(
                        child: JmAnimatedCount(
                          value: issues.length,
                          builder: (context, value) => Text(
                            'Live resource map · $value sites',
                            style: JanMaangTypography.labelMd
                                .copyWith(color: scheme.onSurface),
                          ),
                        ),
                      ),
                      Icon(Icons.open_in_full,
                          size: 14, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),

            // OpenStreetMap attribution, required even on a preview.
            Positioned(
              right: 4,
              top: 4,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '© OpenStreetMap',
                    style: JanMaangTypography.labelMd.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 9,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
