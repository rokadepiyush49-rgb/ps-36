import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/formatters.dart';

/// A Community Pulse tile: a small tinted icon well, a large tabular figure,
/// and a caption underneath.
///
/// The figure counts up on first paint so the number lands rather than simply
/// appearing; screen readers are given the final value, never the count.
class JmStatTile extends StatelessWidget {
  const JmStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.backgroundColor,
    this.labelColor,
    this.compactValue = true,
    this.onTap,
  });

  final int value;
  final String label;

  /// Optional glyph in a tinted well above the figure. Gives the tile a second
  /// way to be told apart in a grid where four figures otherwise look alike.
  final IconData? icon;

  final Color? valueColor;
  final Color? backgroundColor;
  final Color? labelColor;

  /// Formats 4281 as "4,281" using Indian digit grouping.
  final bool compactValue;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tinted = backgroundColor != null;
    final figure = valueColor ?? scheme.primary;

    final body = Padding(
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: figure.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Corners.sm),
              ),
              child: Icon(icon, size: 15, color: figure),
            ),
            const SizedBox(height: Insets.sm),
          ],
          // Flexible + scaleDown so the figure gives way before the tile
          // overflows: these sit in a fixed-aspect grid, and a long number or a
          // large text scale must shrink rather than blow the layout.
          Flexible(
            child: JmAnimatedCount(
              value: value,
              builder: (context, animated) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  compactValue ? Formatters.count(animated) : '$animated',
                  maxLines: 1,
                  style: JanMaangTypography.statNumber.copyWith(color: figure),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: JanMaangTypography.labelMd.copyWith(
                color: labelColor ?? scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: '$label: ${Formatters.count(value)}',
      button: onTap != null,
      excludeSemantics: true,
      child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Corners.lg),
            border: Border.all(
              color: tinted
                  ? figure.withValues(alpha: 0.18)
                  : scheme.outlineVariant,
            ),
            boxShadow: tinted ? null : Shadows.level1,
          ),
        child: onTap == null
            ? body
            : ClipRRect(
                borderRadius: BorderRadius.circular(Corners.lg),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap, child: body),
                ),
              ),
      ),
    );
  }
}
