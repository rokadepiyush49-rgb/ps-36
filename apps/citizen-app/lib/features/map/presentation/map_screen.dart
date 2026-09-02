import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_colors.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../domain/map_issue.dart';
import 'map_controller.dart';
import 'widgets/issue_popup_card.dart';
import 'widgets/jm_issue_marker.dart';
import 'widgets/map_filter_bar.dart';
import 'widgets/map_legend.dart';

/// The interactive map.
///
/// OpenStreetMap raster tiles through flutter_map, with ODbL attribution
/// rendered on the map as the licence requires. Issues are clustered while
/// zoomed out and resolve into individual pins as the citizen zooms in.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.embedded = false});

  /// When embedded in the Track split view the screen drops its own chrome.
  final bool embedded;

  @override
  ConsumerState<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _map = MapController();
  double _zoom = MapViewport.initial.zoom;
  bool _legendOpen = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final issues = ref.watch(filteredIssuesProvider);
    final selectedId = ref.watch(selectedIssueProvider);
    final clusters = IssueClusterer.cluster(issues, _zoom);

    // The Track list can command the camera; follow it when it changes.
    ref.listen(mapCameraProvider, (previous, next) {
      if (previous == next) return;
      _map.move(next.centre, next.zoom);
      setState(() => _zoom = next.zoom);
    });

    final selected = selectedId == null
        ? null
        : issues.where((i) => i.id == selectedId).firstOrNull;

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: MapViewport.initial.centre,
            initialZoom: MapViewport.initial.zoom,
            minZoom: 4,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onPositionChanged: (position, hasGesture) {
              if (position.zoom != _zoom) {
                setState(() => _zoom = position.zoom);
              }
            },
            onTap: (_, _) => ref.read(selectedIssueProvider.notifier).clear(),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.janmaang.app',
              maxNativeZoom: 19,
              tileProvider: NetworkTileProvider(),
            ),
            MarkerLayer(
              markers: <Marker>[
                for (final cluster in clusters)
                  Marker(
                    point: cluster.position,
                    width: cluster.tier.markerSize + 26,
                    height: cluster.tier.markerSize + 26,
                    alignment: Alignment.center,
                    child: cluster.isSingle
                        ? JmIssueMarker(
                            issue: cluster.first,
                            selected: cluster.first.id == selectedId,
                            onTap: () => _selectIssue(cluster.first),
                          )
                        : JmClusterMarker(
                            cluster: cluster,
                            onTap: () => _zoomToCluster(cluster),
                          ),
                  ),
              ],
            ),
            // ODbL attribution, required by the OpenStreetMap licence.
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: <SourceAttribution>[
                TextSourceAttribution(
                  '© OpenStreetMap contributors · ODbL',
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Filters float over the map rather than pushing it down, so the map
        // keeps as much of the screen as possible. Suppressed when embedded in
        // the Track split view, whose list pane already carries the filters —
        // two filter bars on one screen would be redundant and confusing.
        if (!widget.embedded)
          Positioned(
            top: Insets.sm,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: MapFilterBar(
                onLegendToggle: () => setState(() => _legendOpen = !_legendOpen),
                legendOpen: _legendOpen,
              ),
            ),
          ),

        // Embedded, the legend toggle still needs a home.
        if (widget.embedded)
          Positioned(
            top: Insets.md,
            right: Insets.md,
            child: SafeArea(
              bottom: false,
              child: Tooltip(
                message: 'Legend',
                child: JmPressable(
                  onTap: () => setState(() => _legendOpen = !_legendOpen),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _legendOpen
                          ? scheme.primary
                          : scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(Corners.base),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      size: 18,
                      color: _legendOpen ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          right: Insets.md,
          bottom: selected == null ? Insets.navClearance : Insets.sm,
          child: SafeArea(
            child: AnimatedSlide(
              offset: selected == null ? Offset.zero : const Offset(0, 2),
              duration: Motion.medium,
              curve: Motion.curve,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _MapButton(
                    icon: Icons.add,
                    tooltip: 'Zoom in',
                    onTap: () => _nudgeZoom(1),
                  ),
                  const SizedBox(height: Insets.sm),
                  _MapButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom out',
                    onTap: () => _nudgeZoom(-1),
                  ),
                  const SizedBox(height: Insets.sm),
                  _MapButton(
                    icon: Icons.my_location,
                    tooltip: 'Back to my district',
                    onTap: () {
                      ref.read(mapCameraProvider.notifier).reset();
                      ref.read(selectedIssueProvider.notifier).clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_legendOpen)
          Positioned(
            left: Insets.md,
            bottom: Insets.navClearance,
            child: SafeArea(
              child: JmEnter(child: const MapLegend()),
            ),
          ),

        // Selected-issue sheet, rising from the bottom.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: Motion.medium,
            switchInCurve: Motion.enter,
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.35),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: selected == null
                ? const SizedBox.shrink(key: ValueKey<String>('empty'))
                : Padding(
                    key: ValueKey<String>(selected.id),
                    padding: const EdgeInsets.all(Insets.md),
                    child: SafeArea(
                      top: false,
                      child: IssuePopupCard(
                        issue: selected,
                        onClose: () =>
                            ref.read(selectedIssueProvider.notifier).clear(),
                      ),
                    ),
                  ),
          ),
        ),

        if (issues.isEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(Insets.lg),
                  padding: const EdgeInsets.all(Insets.lg),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(Corners.lg),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.filter_alt_off_outlined,
                          size: 28, color: scheme.onSurfaceVariant),
                      const SizedBox(height: Insets.sm),
                      Text(
                        'No issues match these filters',
                        style: JanMaangTypography.bodyMd
                            .copyWith(color: scheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _selectIssue(MapIssue issue) {
    ref.read(selectedIssueProvider.notifier).select(issue.id);
    _map.move(issue.position, _zoom < 14 ? 15 : _zoom);
  }

  void _zoomToCluster(IssueCluster cluster) {
    final next = (_zoom + 2).clamp(4.0, 18.0);
    _map.move(cluster.position, next);
    setState(() => _zoom = next);
  }

  void _nudgeZoom(double delta) {
    final next = (_zoom + delta).clamp(4.0, 18.0);
    _map.move(_map.camera.center, next);
    setState(() => _zoom = next);
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: JmPressable(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
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
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
