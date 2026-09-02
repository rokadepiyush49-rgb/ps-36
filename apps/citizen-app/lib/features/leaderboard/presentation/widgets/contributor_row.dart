import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../../../shared/widgets/jm_card.dart';
import '../../domain/contributor.dart';

/// One row of the leaderboard: rank, movement, who, ward, and the two counts
/// that actually matter — reports filed and verifications given.
class ContributorRow extends StatelessWidget {
  const ContributorRow({super.key, required this.contributor});

  final Contributor contributor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final me = contributor.isCurrentUser;

    return JmCard(
      radius: Corners.base,
      padding: const EdgeInsets.all(Insets.md),
      emphasised: me,
      leadingAccent: me,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text(
              '${contributor.rank}',
              textAlign: TextAlign.center,
              style: JanMaangTypography.withWeight(
                JanMaangTypography.tabularNums,
                FontWeight.w700,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          _Movement(value: contributor.movement),
          const SizedBox(width: Insets.sm),
          _Avatar(contributor: contributor),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        contributor.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: JanMaangTypography.withWeight(
                          JanMaangTypography.bodyMd,
                          FontWeight.w600,
                        ).copyWith(color: scheme.onSurface),
                      ),
                    ),
                    if (me) ...<Widget>[
                      const SizedBox(width: Insets.xs),
                      Text(
                        '· you',
                        style: JanMaangTypography.labelMd
                            .copyWith(color: scheme.secondary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${contributor.ward} · ${contributor.reportsFiled} reports · '
                  '${contributor.verificationsGiven} verified',
                  overflow: TextOverflow.ellipsis,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${contributor.impactScore}',
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.tabularNums,
                  FontWeight.w700,
                ).copyWith(color: scheme.primary),
              ),
              Text(
                'points',
                style: JanMaangTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Up/down/steady indicator. Uses an arrow as well as colour so movement is
/// legible without relying on hue.
class _Movement extends StatelessWidget {
  const _Movement({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (value == 0) {
      return SizedBox(
        width: 22,
        child: Center(
          child: Container(
            width: 8,
            height: 2,
            color: scheme.outlineVariant,
          ),
        ),
      );
    }

    final up = value > 0;
    final colour =
        up ? JanMaangColors.tertiary : JanMaangColors.error;

    return SizedBox(
      width: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 18,
            color: colour,
          ),
          Text(
            '${value.abs()}',
            style: JanMaangTypography.labelMd
                .copyWith(color: colour, fontSize: 9, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.contributor});

  final Contributor contributor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Deterministic tint from the brand spectrum, so a person keeps the same
    // colour across sessions without needing an avatar image.
    const palette = <Color>[
      JanMaangColors.brandNavy,
      JanMaangColors.brandBlue,
      JanMaangColors.brandGreen,
      JanMaangColors.brandOrange,
      JanMaangColors.brandRed,
    ];
    final tint = palette[contributor.id.hashCode.abs() % palette.length];

    return AnimatedContainer(
      duration: Motion.medium,
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: contributor.isCurrentUser ? scheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        contributor.initials,
        style: JanMaangTypography.withWeight(
          JanMaangTypography.labelMd,
          FontWeight.w700,
        ).copyWith(color: tint, letterSpacing: 0),
      ),
    );
  }
}
