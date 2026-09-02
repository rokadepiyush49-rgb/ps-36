import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/demand_enums.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_provenance_badge.dart';
import '../../../shared/widgets/jm_states.dart';
import '../../../shared/widgets/jm_status_chip.dart';
import '../../map/domain/map_issue.dart';
import '../../map/presentation/map_controller.dart';
import '../../map/presentation/map_screen.dart';
import '../../map/presentation/widgets/map_filter_bar.dart';
import '../domain/demand.dart';
import 'demand_providers.dart';

/// Track — search, filter and follow issues, on a list and a map that stay in
/// step with each other.
///
/// Two modes on mobile because a half-height map and a half-height list serve
/// neither well; on tablet and desktop they sit side by side, since there is
/// room for both. Selecting a row flies the map to it and selects its pin —
/// the behaviour the brief asks for in §12.
class TrackScreen extends ConsumerStatefulWidget {
  const TrackScreen({super.key});

  @override
  ConsumerState<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends ConsumerState<TrackScreen> {
  _TrackView _view = _TrackView.list;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= Breakpoints.medium;

    return Scaffold(
      appBar: JmAppBar(
        showBrand: true,
        onProfile: () => context.pushNamed(AppRoute.profile.name),
      ),
      body: isWide ? _buildSplit(context) : _buildStacked(context),
    );
  }

  /// Tablet and desktop: list beside a persistent map.
  Widget _buildSplit(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 420,
          child: _IssueList(onFocus: _focus),
        ),
        VerticalDivider(width: 1, color: scheme.outlineVariant),
        const Expanded(child: MapScreen(embedded: true)),
      ],
    );
  }

  /// Mobile: one at a time, with a segmented switch.
  Widget _buildStacked(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.marginMobile,
            Insets.md,
            Insets.marginMobile,
            Insets.sm,
          ),
          child: _ViewSwitch(
            view: _view,
            onChanged: (v) => setState(() => _view = v),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Motion.medium,
            switchInCurve: Motion.enter,
            child: _view == _TrackView.list
                ? _IssueList(key: const ValueKey<String>('list'), onFocus: _focus)
                : const _MapPane(key: ValueKey<String>('map')),
          ),
        ),
      ],
    );
  }

  /// Move the map to an issue and select it, switching view on mobile.
  void _focus(MapIssue issue) {
    ref.read(mapCameraProvider.notifier).focusOn(issue);
    if (MediaQuery.of(context).size.width < Breakpoints.medium) {
      setState(() => _view = _TrackView.map);
    }
  }
}

enum _TrackView { list, map }

class _MapPane extends StatelessWidget {
  const _MapPane({super.key});

  @override
  Widget build(BuildContext context) => const MapScreen(embedded: true);
}

class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.view, required this.onChanged});

  final _TrackView view;
  final ValueChanged<_TrackView> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(Corners.base),
      ),
      child: Row(
        children: <Widget>[
          for (final option in _TrackView.values)
            Expanded(
              child: JmPressable(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: Motion.medium,
                  curve: Motion.curve,
                  padding: const EdgeInsets.symmetric(vertical: Insets.sm),
                  decoration: BoxDecoration(
                    color: option == view
                        ? scheme.surfaceContainerLowest
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Corners.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        option == _TrackView.list
                            ? Icons.view_list_outlined
                            : Icons.map_outlined,
                        size: 16,
                        color: option == view
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Insets.sm),
                      Text(
                        option == _TrackView.list ? 'List' : 'Map',
                        style: JanMaangTypography.labelMd.copyWith(
                          color: option == view
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Search, filters, my demands, and every issue in the district.
class _IssueList extends ConsumerWidget {
  const _IssueList({super.key, required this.onFocus});

  final void Function(MapIssue issue) onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final issues = ref.watch(filteredIssuesProvider);
    final filter = ref.watch(issueFilterProvider);
    final mine = ref.watch(myDemandsProvider);
    final selectedId = ref.watch(selectedIssueProvider);

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: Insets.sm),
          child: MapFilterBar(onLegendToggle: _noop, legendOpen: false),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.marginMobile,
              0,
              Insets.marginMobile,
              Insets.navClearance,
            ),
            children: <Widget>[
              mine.maybeWhen(
                data: (demands) {
                  final awaiting = demands
                      .where((d) => d.status == DemandStatus.inProgress)
                      .toList();
                  if (awaiting.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: <Widget>[
                      for (final demand in awaiting) ...<Widget>[
                        _VerificationRequestCard(demand: demand),
                        const SizedBox(height: Insets.md),
                      ],
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      filter.isEmpty
                          ? 'All issues'
                          : '${issues.length} matching',
                      style: JanMaangTypography.titleLg
                          .copyWith(color: scheme.onSurface),
                    ),
                  ),
                  if (!filter.isEmpty)
                    TextButton(
                      onPressed: ref.read(issueFilterProvider.notifier).clear,
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: Insets.sm),

              if (issues.isEmpty)
                JmEmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No issues match',
                  message: 'Try widening the filters, or report something new '
                      'in your area.',
                  actionLabel: 'Report a need',
                  onAction: () => context.pushNamed(AppRoute.report.name),
                )
              else
                for (var i = 0; i < issues.length; i++) ...<Widget>[
                  JmEnter(
                    index: i,
                    child: _IssueRow(
                      issue: issues[i],
                      selected: issues[i].id == selectedId,
                      onTap: () => onFocus(issues[i]),
                      onOpen: issues[i].demandId == null
                          ? null
                          : () => context.pushNamed(
                                AppRoute.demandDetail.name,
                                pathParameters: <String, String>{
                                  'id': issues[i].demandId!,
                                },
                              ),
                    ),
                  ),
                  const SizedBox(height: Insets.sm),
                ],
            ],
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}

/// A row in the Track list. Carries the density tier as a coloured rail so the
/// list and the map share one visual language for concentration.
class _IssueRow extends StatelessWidget {
  const _IssueRow({
    required this.issue,
    required this.selected,
    required this.onTap,
    this.onOpen,
  });

  final MapIssue issue;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tier = issue.displayTier;

    return JmCard(
      onTap: onTap,
      radius: Corners.base,
      emphasised: selected,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(width: 4, color: tier.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: tier.color.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(issue.category.icon,
                              size: 17, color: tier.color),
                        ),
                        const SizedBox(width: Insets.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                issue.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: JanMaangTypography.withWeight(
                                  JanMaangTypography.bodyMd,
                                  FontWeight.w600,
                                ).copyWith(color: scheme.onSurface),
                              ),
                              Text(
                                '${issue.ward} · ${Formatters.relative(issue.reportedAt)}',
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
                              '${issue.reportCount}',
                              style: JanMaangTypography.withWeight(
                                JanMaangTypography.tabularNums,
                                FontWeight.w700,
                              ).copyWith(color: tier.color),
                            ),
                            Text(
                              issue.reportCount == 1 ? 'report' : 'reports',
                              style: JanMaangTypography.labelMd.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Insets.sm),
                    Row(
                      children: <Widget>[
                        JmStatusChip.forStatus(issue.status, dense: true),
                        const SizedBox(width: Insets.xs),
                        JmStatusChip.forSeverity(issue.severity, dense: true),
                        const Spacer(),
                        if (onOpen != null)
                          JmPressable(
                            onTap: onOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Details',
                                  style: JanMaangTypography.labelMd
                                      .copyWith(color: scheme.secondary),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 14, color: scheme.secondary),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Insets.xs),
                    JmProvenanceBadge(stamp: issue.stamp, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "The contractor has marked X as completed. Can you confirm?"
class _VerificationRequestCard extends StatelessWidget {
  const _VerificationRequestCard({required this.demand});

  final Demand demand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      backgroundColor: scheme.tertiaryFixed,
      borderColor: scheme.tertiaryFixedDim,
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.fact_check, size: 18, color: scheme.onTertiaryFixed),
              const SizedBox(width: Insets.sm),
              Text(
                'Verification Request',
                style: JanMaangTypography.titleLg
                    .copyWith(color: scheme.onTertiaryFixed),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          Text(
            'The contractor has marked ${demand.title} (${demand.ward}) as '
            'completed. Can you confirm it is actually working?',
            style: JanMaangTypography.bodySm
                .copyWith(color: scheme.onTertiaryFixed),
          ),
          const SizedBox(height: Insets.md),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () => context.pushNamed(
                    AppRoute.verify.name,
                    pathParameters: <String, String>{'id': demand.id},
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    textStyle: JanMaangTypography.labelMd,
                  ),
                  child: const Text("Yes, it's fixed"),
                ),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushNamed(
                    AppRoute.verify.name,
                    pathParameters: <String, String>{'id': demand.id},
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('No, still broken'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
