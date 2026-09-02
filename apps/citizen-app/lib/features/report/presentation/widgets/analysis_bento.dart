import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../shared/widgets/jm_card.dart';
import '../../../../shared/widgets/jm_status_chip.dart';
import '../../domain/report_draft.dart';

/// The three extraction cards — Identified Need, Location Mentioned, Assessed
/// Severity. Three across on wide screens, stacked on mobile.
class AnalysisBento extends StatelessWidget {
  const AnalysisBento({
    super.key,
    required this.analysis,
    this.pinnedLocation = '',
  });

  final ReportAnalysis analysis;
  final String pinnedLocation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.medium;

    final cards = <Widget>[
      _BentoCard(
        overline: 'IDENTIFIED NEED',
        overlineIcon: Icons.category_outlined,
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.secondaryFixed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                analysis.category.icon,
                size: 20,
                color: scheme.onSecondaryFixed,
              ),
            ),
            const SizedBox(width: Insets.sm),
            Expanded(
              child: Text(
                analysis.title,
                style: JanMaangTypography.titleLg
                    .copyWith(color: scheme.onSurface),
              ),
            ),
          ],
        ),
      ),
      _BentoCard(
        overline: 'LOCATION MENTIONED',
        overlineIcon: Icons.place_outlined,
        child: Text(
          pinnedLocation.isNotEmpty
              ? pinnedLocation
              : (analysis.mentionedLocation.isNotEmpty
                  ? analysis.mentionedLocation
                  : 'Not detected'),
          style: JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
        ),
      ),
      _BentoCard(
        overline: 'ASSESSED SEVERITY',
        overlineIcon: Icons.priority_high,
        child: Align(
          alignment: Alignment.centerLeft,
          child: JmStatusChip.forSeverity(analysis.severity),
        ),
      ),
    ];

    if (!isWide) {
      return Column(
        children: <Widget>[
          for (var i = 0; i < cards.length; i++) ...<Widget>[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: Insets.md),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < cards.length; i++) ...<Widget>[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) const SizedBox(width: Insets.md),
          ],
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.overline,
    required this.overlineIcon,
    required this.child,
  });

  final String overline;
  final IconData overlineIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return JmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(overlineIcon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: Insets.xs),
              Text(
                overline,
                style: JanMaangTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          child,
        ],
      ),
    );
  }
}
