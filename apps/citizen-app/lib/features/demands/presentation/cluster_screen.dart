import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_map_view.dart';
import '../../../shared/widgets/jm_rank_badge.dart';
import '../../../shared/widgets/jm_status_chip.dart';
import '../../../shared/widgets/jm_states.dart';
import '../domain/demand_cluster.dart';
import 'demand_providers.dart';

/// "You are not alone." — the Stitch demand-cluster screen.
///
/// The hero line with the report count, the cluster map, the people-affected
/// metric with the analysis breakdown, and the join / different-issue actions.
class ClusterScreen extends ConsumerStatefulWidget {
  const ClusterScreen({super.key, required this.clusterId});

  final String clusterId;

  @override
  ConsumerState<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends ConsumerState<ClusterScreen> {
  bool _joining = false;

  @override
  Widget build(BuildContext context) {
    final clusterAsync = ref.watch(clusterProvider(widget.clusterId));

    return Scaffold(
      appBar: JmAppBar.task(title: 'Similar reports'),
      body: clusterAsync.when(
        loading: () => const JmLoader(message: 'Finding similar reports…'),
        error: (error, _) => JmErrorView(
          error: error,
          onRetry: () => ref.invalidate(clusterProvider(widget.clusterId)),
        ),
        data: (cluster) => _Body(
          cluster: cluster,
          joining: _joining,
          onJoin: () => _join(cluster),
          onDifferent: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  Future<void> _join(DemandCluster cluster) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _joining = true);
    try {
      await ref
          .read(demandsRepositoryProvider)
          .joinCluster(cluster.id, user.uid);
      if (!mounted) return;
      ref.invalidate(clusterProvider(cluster.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your voice was added. This demand just moved up.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.cluster,
    required this.joining,
    required this.onJoin,
    required this.onDifferent,
  });

  final DemandCluster cluster;
  final bool joining;
  final VoidCallback onJoin;
  final VoidCallback onDifferent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.marginMobile,
        Insets.lg,
        Insets.marginMobile,
        Insets.xl,
      ),
      children: <Widget>[
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.sm,
                vertical: Insets.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(Corners.sm),
              ),
              child: Text(
                cluster.code,
                style: JanMaangTypography.tabularNums
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            if (cluster.rank != null)
              JmRankBadge(rank: cluster.rank!, total: cluster.totalRanked),
            JmStatusChip.category(cluster.category, dense: true),
          ],
        ),
        const SizedBox(height: Insets.md),
        Text(
          'You are not alone.',
          style:
              JanMaangTypography.displayLgMobile.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Insets.sm),
        Text(
          '${cluster.reportCount} people have reported the same issue in this '
          'area.',
          style: JanMaangTypography.bodyLg
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Insets.lg),

        JmCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Text(
                  'Demand Cluster',
                  style: JanMaangTypography.titleLg
                      .copyWith(color: scheme.onSurface),
                ),
              ),
              SizedBox(
                height: 200,
                child: JmMapView(
                  showClusterDensity: true,
                  pins: <JmMapPin>[
                    for (var i = 0; i < 14; i++)
                      JmMapPin(
                        x: 0.34 + ((i * 37) % 100) / 380,
                        y: 0.3 + ((i * 53) % 100) / 380,
                        emphasised: i == 0,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.md),

        JmCard(
          padding: const EdgeInsets.all(Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Formatters.count(cluster.peopleAffected),
                style: JanMaangTypography.displayLgMobile
                    .copyWith(color: scheme.primary),
              ),
              Text(
                'people affected',
                style: JanMaangTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Insets.lg),
              Text(
                'Analysis',
                style: JanMaangTypography.titleLg
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Insets.md),
              _AnalysisRow(
                icon: Icons.assignment,
                label: 'Total Reports',
                value: '${cluster.reportCount} related reports',
              ),
              const SizedBox(height: Insets.md),
              _AnalysisRow(
                icon: Icons.merge,
                label: 'Consolidated',
                value: '${cluster.mergedDuplicates} duplicate reports merged',
              ),
              const SizedBox(height: Insets.md),
              _AnalysisRow(
                icon: Icons.house,
                label: 'Impact Area',
                value: '${cluster.habitationsAffected} habitations affected',
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.lg),

        Text(
          'Add your voice to this demand',
          style: JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Insets.xs),
        Text(
          'Joining existing demands increases their priority in the public '
          'ledger.',
          style:
              JanMaangTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Insets.md),
        FilledButton.icon(
          onPressed: cluster.hasJoined || joining ? null : onJoin,
          icon: joining
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : Icon(cluster.hasJoined ? Icons.check_circle : Icons.add_circle,
                  size: 20),
          label: Text(cluster.hasJoined ? 'Voice added' : 'Join this demand'),
        ),
        const SizedBox(height: Insets.sm),
        OutlinedButton(
          onPressed: onDifferent,
          child: const Text('This is a different issue'),
        ),
      ],
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: Insets.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: JanMaangTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    JanMaangTypography.bodyMd.copyWith(color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
