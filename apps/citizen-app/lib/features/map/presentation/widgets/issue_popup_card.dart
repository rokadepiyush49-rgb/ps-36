import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/jm_provenance_badge.dart';
import '../../../../shared/widgets/jm_status_chip.dart';
import '../../domain/map_issue.dart';

/// The card that rises when a pin is selected.
///
/// Carries everything the brief asks a popup to answer — what, where, how bad,
/// how many, what stage, when — plus the provenance line, because a figure
/// without its source is exactly what this product exists to replace.
class IssuePopupCard extends ConsumerWidget {
  const IssuePopupCard({
    super.key,
    required this.issue,
    required this.onClose,
  });

  final MapIssue issue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final tier = issue.displayTier;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Corners.lg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: JanMaangColors.shadowModal,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Tier strip — the density colour restated as a full-width bar so it
          // is legible even to someone who cannot separate the pin hues.
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: tier.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Corners.lg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tier.color.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        issue.category.filledIcon,
                        size: 20,
                        color: tier.color,
                      ),
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            issue.title,
                            style: JanMaangTypography.withWeight(
                              JanMaangTypography.bodyLg,
                              FontWeight.w700,
                            ).copyWith(color: scheme.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${issue.code} · ${issue.ward}, ${issue.district}',
                            style: JanMaangTypography.bodySm
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: scheme.onSurfaceVariant,
                      tooltip: 'Close',
                      onPressed: onClose,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                if (issue.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Insets.sm),
                  Text(
                    issue.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: JanMaangTypography.bodySm
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],

                const SizedBox(height: Insets.md),
                Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _Metric(
                      icon: Icons.groups_outlined,
                      label: '${issue.reportCount} '
                          '${issue.reportCount == 1 ? 'report' : 'reports'}',
                      color: tier.color,
                      emphasised: true,
                    ),
                    if (issue.peopleAffected > 0)
                      _Metric(
                        icon: Icons.people_outline,
                        label:
                            '${Formatters.count(issue.peopleAffected)} affected',
                        color: scheme.onSurfaceVariant,
                      ),
                    _Metric(
                      icon: Icons.schedule,
                      label: Formatters.relative(issue.reportedAt),
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: Insets.sm),
                Row(
                  children: <Widget>[
                    JmStatusChip.forStatus(issue.status, dense: true),
                    const SizedBox(width: Insets.sm),
                    JmStatusChip.forSeverity(issue.severity, dense: true),
                  ],
                ),

                const SizedBox(height: Insets.md),
                Divider(color: scheme.outlineVariant, height: 1),
                const SizedBox(height: Insets.sm),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: JmProvenanceBadge(stamp: issue.stamp, compact: true),
                    ),
                    if (issue.demandId != null)
                      JmPressable(
                        onTap: () => context.pushNamed(
                          AppRoute.demandDetail.name,
                          pathParameters: <String, String>{
                            'id': issue.demandId!,
                          },
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'View details',
                              style: JanMaangTypography.labelMd
                                  .copyWith(color: scheme.secondary),
                            ),
                            const SizedBox(width: Insets.xs),
                            Icon(Icons.arrow_forward,
                                size: 14, color: scheme.secondary),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.color,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: Insets.xs),
        Text(
          label,
          style: (emphasised
                  ? JanMaangTypography.withWeight(
                      JanMaangTypography.bodySm, FontWeight.w700)
                  : JanMaangTypography.bodySm)
              .copyWith(color: color),
        ),
      ],
    );
  }
}
