import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// The dashed evidence-capture target — "Tap to Capture Evidence" /
/// "Upload a photo" — plus the thumbnail grid of what has been captured.
class JmPhotoDropzone extends StatelessWidget {
  const JmPhotoDropzone({
    super.key,
    required this.onTap,
    this.title = 'Tap to Capture Evidence',
    this.subtitle = 'Photos are auto-geotagged and timestamped.',
    this.icon = Icons.add_a_photo_outlined,
    this.height = 148,
    this.paths = const <String>[],
    this.onRemove,
  });

  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;
  final double height;
  final List<String> paths;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Corners.lg),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: scheme.outlineVariant,
              radius: Corners.lg,
            ),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 30, color: scheme.onSurfaceVariant),
                  const SizedBox(height: Insets.sm),
                  Text(
                    title,
                    style: JanMaangTypography.bodyMd
                        .copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: Insets.xs),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Insets.md),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: JanMaangTypography.bodySm
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (paths.isNotEmpty) ...<Widget>[
          const SizedBox(height: Insets.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paths.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: Insets.sm,
              mainAxisSpacing: Insets.sm,
            ),
            itemBuilder: (context, index) => _Thumbnail(
              path: paths[index],
              onRemove: onRemove == null ? null : () => onRemove!(index),
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path, this.onRemove});

  final String path;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = File(path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(Corners.base),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (file.existsSync())
            Image.file(file, fit: BoxFit.cover)
          else
            ColoredBox(
              color: scheme.surfaceContainerHigh,
              child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
            ),
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 14, color: scheme.onSurface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
