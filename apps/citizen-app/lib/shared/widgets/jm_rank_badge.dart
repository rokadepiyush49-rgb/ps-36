import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// Rank badge from the Home demand list. Rank #1 is solid primary with a star;
/// every other rank is secondary-container with a trending-up arrow.
class JmRankBadge extends StatelessWidget {
  const JmRankBadge({super.key, required this.rank, this.total});

  final int rank;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTop = rank == 1;
    final background = isTop ? scheme.primary : scheme.secondaryContainer;
    final foreground = isTop ? scheme.onPrimary : scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.sm,
        vertical: Insets.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Corners.sm),
        boxShadow: isTop
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isTop ? Icons.star : Icons.trending_up,
            size: 12,
            color: foreground,
          ),
          const SizedBox(width: Insets.xs),
          Text(
            total == null ? 'Rank #$rank' : 'Ranked #$rank of $total',
            style: JanMaangTypography.labelMd.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
