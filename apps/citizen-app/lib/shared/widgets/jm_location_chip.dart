import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// The pill on the Home header showing where the citizen is reporting from.
/// One of the few genuinely rounded shapes the system allows, because it reads
/// as a status indicator rather than a primary control.
class JmLocationChip extends StatelessWidget {
  const JmLocationChip({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(Corners.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.location_on, size: 14, color: scheme.primary),
              const SizedBox(width: Insets.xs),
              Text(
                label,
                style:
                    JanMaangTypography.labelMd.copyWith(color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
