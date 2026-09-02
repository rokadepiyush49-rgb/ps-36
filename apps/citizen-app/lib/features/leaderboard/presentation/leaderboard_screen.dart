import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_colors.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../../../shared/models/provenance.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_provenance_badge.dart';
import '../../../shared/widgets/jm_states.dart';
import '../data/leaderboard_repository.dart';
import '../domain/contributor.dart';
import 'widgets/contributor_row.dart';
import 'widgets/podium.dart';

/// Community participation, ranked.
///
/// The ordering rewards verification most heavily: anyone can file a report,
/// far fewer people go back and confirm whether the work was actually done,
/// and that check is what the whole ledger rests on.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final period = ref.watch(leaderboardPeriodProvider);
    final board = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: const JmAppBar(showBrand: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leaderboardProvider);
          await ref.read(leaderboardProvider.future);
        },
        child: board.when(
          loading: () => const JmLoader(message: 'Counting contributions…'),
          error: (error, _) => JmErrorView(
            error: error,
            onRetry: () => ref.invalidate(leaderboardProvider),
          ),
          data: (contributors) {
            if (contributors.isEmpty) {
              return const JmEmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No contributions yet',
                message: 'Once people start reporting and verifying in your '
                    'district, the leaderboard fills up here.',
              );
            }

            final podium = contributors.take(3).toList();
            final rest = contributors.skip(3).toList();
            final me = contributors.where((c) => c.isCurrentUser).firstOrNull;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Insets.marginMobile,
                Insets.lg,
                Insets.marginMobile,
                Insets.navClearance,
              ),
              children: <Widget>[
                JmEnter(
                  child: Text(
                    'Leaderboard',
                    style: JanMaangTypography.displayLgMobile
                        .copyWith(color: scheme.onSurface),
                  ),
                ),
                const SizedBox(height: Insets.sm),
                JmEnter(
                  index: 1,
                  child: Text(
                    'Who is doing the civic work in Yadgir — reporting, joining '
                    'and checking that fixes actually happened.',
                    style: JanMaangTypography.bodyMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: Insets.md),

                JmEnter(index: 2, child: _PeriodSelector(selected: period)),
                const SizedBox(height: Insets.lg),

                JmEnter(index: 3, child: Podium(top: podium)),
                const SizedBox(height: Insets.lg),

                if (me != null && me.rank > 3) ...<Widget>[
                  JmEnter(index: 4, child: _YourStanding(contributor: me)),
                  const SizedBox(height: Insets.lg),
                ],

                Text(
                  'ALL CONTRIBUTORS',
                  style: JanMaangTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: Insets.sm),

                for (var i = 0; i < rest.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: JmEnter(
                      index: 5 + i,
                      child: ContributorRow(contributor: rest[i]),
                    ),
                  ),

                const SizedBox(height: Insets.md),
                Center(
                  child: JmProvenanceBadge(
                    stamp: const ProvenanceStamp(
                      provenance: Provenance.syntheticRural,
                      precision: LocationPrecision.wardCentroid,
                    ),
                  ),
                ),
                const SizedBox(height: Insets.sm),
                Text(
                  'Ranking weights verification most heavily, then verified '
                  'reports, then reports filed, then demands joined. No metric '
                  'here depends on resolution time — the source data has no '
                  'closure timestamp.',
                  textAlign: TextAlign.center,
                  style: JanMaangTypography.bodySm.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.selected});

  final LeaderboardPeriod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(Corners.base),
      ),
      child: Row(
        children: <Widget>[
          for (final period in LeaderboardPeriod.values)
            Expanded(
              child: JmPressable(
                onTap: () =>
                    ref.read(leaderboardPeriodProvider.notifier).set(period),
                child: AnimatedContainer(
                  duration: Motion.medium,
                  curve: Motion.curve,
                  padding: const EdgeInsets.symmetric(vertical: Insets.sm),
                  decoration: BoxDecoration(
                    color: period == selected
                        ? scheme.surfaceContainerLowest
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Corners.sm),
                    boxShadow: period == selected
                        ? const <BoxShadow>[
                            BoxShadow(
                              color: JanMaangColors.shadowAmbient,
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      period.label,
                      style: JanMaangTypography.labelMd.copyWith(
                        color: period == selected
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The signed-in citizen's own row, pinned above the list so they never have
/// to scroll to find themselves.
class _YourStanding extends StatelessWidget {
  const _YourStanding({required this.contributor});

  final Contributor contributor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moved = contributor.movement;

    return JmCard(
      backgroundColor: scheme.primary,
      borderColor: scheme.primary,
      padding: const EdgeInsets.all(Insets.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              '#${contributor.rank}',
              style: JanMaangTypography.withWeight(
                JanMaangTypography.tabularNums,
                FontWeight.w700,
              ).copyWith(color: scheme.onPrimary),
            ),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your standing',
                  style: JanMaangTypography.labelMd
                      .copyWith(color: scheme.primaryFixedDim),
                ),
                const SizedBox(height: 2),
                JmAnimatedCount(
                  value: contributor.impactScore,
                  builder: (context, value) => Text(
                    '$value impact points',
                    style: JanMaangTypography.withWeight(
                      JanMaangTypography.bodyLg,
                      FontWeight.w700,
                    ).copyWith(color: scheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (moved != 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  moved > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: moved > 0
                      ? JanMaangColors.tertiaryFixed
                      : JanMaangColors.errorContainer,
                ),
                const SizedBox(width: 2),
                Text(
                  '${moved.abs()}',
                  style: JanMaangTypography.tabularNums.copyWith(
                    color: moved > 0
                        ? JanMaangColors.tertiaryFixed
                        : JanMaangColors.errorContainer,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
