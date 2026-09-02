import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/jm_card.dart';
import '../../../../shared/widgets/jm_rank_badge.dart';
import '../../../../shared/widgets/jm_status_chip.dart';
import '../../domain/demand.dart';

/// A row in the "Near You" list: category avatar, title, ward + distance, and
/// either a rank badge or a status chip on the right. The top-ranked demand
/// gets the emphasised treatment with a primary border and left accent bar.
class DemandListCard extends StatelessWidget {
  const DemandListCard({super.key, required this.demand, this.onTap});

  final Demand demand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final emphasised = demand.isTopRanked;

    final subtitle = <String>[
      if (demand.ward.isNotEmpty) demand.ward,
      if (demand.distanceKm != null) Formatters.distance(demand.distanceKm!),
    ].join(' • ');

    return JmCard(
      onTap: onTap,
      radius: Corners.base,
      emphasised: emphasised,
      leadingAccent: emphasised,
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: emphasised
                  ? scheme.surfaceContainerHighest
                  : scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              demand.category.icon,
              size: 18,
              color: emphasised ? scheme.onSurface : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  demand.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: JanMaangTypography.withWeight(
                    JanMaangTypography.bodyMd,
                    FontWeight.w700,
                  ).copyWith(color: scheme.onSurface),
                ),
                if (subtitle.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: JanMaangTypography.bodySm
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Insets.sm),
          if (demand.rank != null)
            JmRankBadge(rank: demand.rank!)
          else
            JmStatusChip.forStatus(demand.status, dense: true),
        ],
      ),
    );
  }
}
