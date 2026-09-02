import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// Map surface for the "Live Resource Map" and the demand-cluster view.
///
/// Google Maps needs a platform API key in the native manifests. Until one is
/// provisioned ([AppConfig.mapsEnabled] is false) this renders a styled
/// cartographic placeholder with the report pins plotted on it, so the screen
/// keeps the composition the design specifies instead of showing a grey box.
class JmMapView extends StatelessWidget {
  const JmMapView({
    super.key,
    this.pins = const <JmMapPin>[],
    this.caption,
    this.onTap,
    this.showClusterDensity = false,
  });

  final List<JmMapPin> pins;
  final String? caption;
  final VoidCallback? onTap;

  /// Draws a heat-like concentration around the centroid, matching the
  /// dense-cluster illustration on the "You are not alone" screen.
  final bool showClusterDensity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
            CustomPaint(
              painter: _CartographyPainter(
                scheme: scheme,
                pins: pins,
                showDensity: showClusterDensity,
              ),
            ),
            if (onTap != null)
              Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            if (caption != null)
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
                      color: scheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(Corners.base),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            caption!,
                            style: JanMaangTypography.labelMd
                                .copyWith(color: scheme.onSurface),
                          ),
                        ),
                        Icon(
                          Icons.open_in_full,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
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

/// A report location plotted on [JmMapView]. Coordinates are normalised 0–1
/// within the widget so the placeholder can position them without a projection.
class JmMapPin {
  const JmMapPin({
    required this.x,
    required this.y,
    this.emphasised = false,
  });

  final double x;
  final double y;
  final bool emphasised;
}

/// Paints the light institutional cartography the design calls for: soft blue
/// and green ground tones, a road network, and crimson/navy report pins.
class _CartographyPainter extends CustomPainter {
  _CartographyPainter({
    required this.scheme,
    required this.pins,
    required this.showDensity,
  });

  final ColorScheme scheme;
  final List<JmMapPin> pins;
  final bool showDensity;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = Paint()..color = scheme.surfaceContainerLow;
    canvas.drawRect(Offset.zero & size, ground);

    // Parcels of green space.
    final parcel = Paint()
      ..color = scheme.tertiaryFixed.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.55,
            size.width * 0.3, size.height * 0.3),
        const Radius.circular(6),
      ),
      parcel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.08,
            size.width * 0.3, size.height * 0.24),
        const Radius.circular(6),
      ),
      parcel,
    );

    // Water body.
    final water = Paint()..color = scheme.primaryFixed.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.6,
            size.width * 0.28, size.height * 0.32),
        const Radius.circular(10),
      ),
      water,
    );

    // Road network — a few arterials over a light grid.
    final minor = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      final dy = size.height * i / 6;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), minor);
      final dx = size.width * i / 6;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), minor);
    }

    final arterial = Paint()
      ..color = scheme.surfaceContainerLowest
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.42),
      Offset(size.width, size.height * 0.34),
      arterial,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, 0),
      Offset(size.width * 0.46, size.height),
      arterial,
    );

    if (showDensity && pins.isNotEmpty) {
      final cx = pins.map((p) => p.x).reduce((a, b) => a + b) / pins.length;
      final cy = pins.map((p) => p.y).reduce((a, b) => a + b) / pins.length;
      final centre = Offset(cx * size.width, cy * size.height);
      final radius = math.min(size.width, size.height) * 0.34;
      for (final step in <double>[1.0, 0.66, 0.4]) {
        canvas.drawCircle(
          centre,
          radius * step,
          Paint()
            ..color = scheme.primary.withValues(alpha: 0.07 + (1 - step) * 0.06),
        );
      }
    }

    for (final pin in pins) {
      final centre = Offset(pin.x * size.width, pin.y * size.height);
      final colour = pin.emphasised ? scheme.error : scheme.primary;
      canvas.drawCircle(
        centre,
        pin.emphasised ? 7 : 4.5,
        Paint()..color = colour,
      );
      canvas.drawCircle(
        centre,
        pin.emphasised ? 7 : 4.5,
        Paint()
          ..color = scheme.surfaceContainerLowest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CartographyPainter oldDelegate) =>
      oldDelegate.pins != pins ||
      oldDelegate.scheme != scheme ||
      oldDelegate.showDensity != showDensity;
}
