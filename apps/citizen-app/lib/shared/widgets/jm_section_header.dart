import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// "Community Pulse" / "Near You" section header: a navy glyph in a tinted
/// well, a title, and an optional trailing action.
///
/// The well is what makes a header read as a header when it sits between two
/// cards — a bare icon at this size disappears into the page.
class JmSectionHeader extends StatelessWidget {
  const JmSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: scheme.primaryFixed,
              borderRadius: BorderRadius.circular(Corners.sm + 2),
            ),
            child: Icon(icon, size: 17, color: scheme.onPrimaryFixedVariant),
          ),
          const SizedBox(width: Insets.sm + Insets.xs),
        ],
        Expanded(
          child: Text(
            title,
            style: JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}
