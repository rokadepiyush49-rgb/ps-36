import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_states.dart';
import '../../../shared/widgets/jm_status_chip.dart';
import '../domain/ledger_entry.dart';

final ledgerEntriesProvider = StreamProvider.autoDispose<List<LedgerEntry>>(
  (ref) => ref.watch(ledgerRepositoryProvider).watchEntries(),
);

final ledgerSummaryProvider = FutureProvider.autoDispose<LedgerSummary>(
  (ref) => ref.watch(ledgerRepositoryProvider).getSummary(),
);

/// Public Ledger — the fourth destination in the Stitch bottom navigation.
///
/// Every rupee allocated against a citizen demand, what stage it reached, and
/// whether citizens confirmed the work. Built in the same institutional
/// language as the rest of the app: tabular figures, hairline cards, teal for
/// verified public impact.
class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final entries = ref.watch(ledgerEntriesProvider);
    final summary = ref.watch(ledgerSummaryProvider);

    return Scaffold(
      appBar: const JmAppBar(showBrand: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ledgerEntriesProvider);
          ref.invalidate(ledgerSummaryProvider);
          await ref.read(ledgerSummaryProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Insets.marginMobile,
            Insets.lg,
            Insets.marginMobile,
            Insets.navClearance,
          ),
          children: <Widget>[
            Text(
              'Public Ledger',
              style: JanMaangTypography.displayLgMobile
                  .copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: Insets.sm),
            Text(
              'Every rupee allocated against a citizen demand, and whether the '
              'community confirmed the work.',
              style: JanMaangTypography.bodyMd
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: Insets.lg),

            summary.when(
              loading: () => const SizedBox(
                height: 120,
                child: JmInlineLoader(message: 'Totalling allocations…'),
              ),
              error: (error, _) => JmErrorView(error: error),
              data: (data) => _SummaryBand(summary: data),
            ),
            const SizedBox(height: Insets.lg),

            entries.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: Insets.xl),
                child: JmInlineLoader(message: 'Loading the ledger…'),
              ),
              error: (error, _) => JmErrorView(
                error: error,
                onRetry: () => ref.invalidate(ledgerEntriesProvider),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return const JmEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No allocations yet',
                    message: 'Once demands in your district are funded, every '
                        'line item appears here.',
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final entry in rows) ...<Widget>[
                      _LedgerRow(entry: entry),
                      const SizedBox(height: Insets.md),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBand extends StatelessWidget {
  const _SummaryBand({required this.summary});

  final LedgerSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TOTAL ALLOCATED',
            style: JanMaangTypography.labelMd
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.xs),
          Text(
            Formatters.rupees(summary.totalAllocated),
            style: JanMaangTypography.displayLgMobile
                .copyWith(color: scheme.primary),
          ),
          const SizedBox(height: Insets.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  value: summary.projectsFunded,
                  label: 'Funded',
                  color: scheme.onSurface,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: summary.citizenVerified,
                  label: 'Citizen verified',
                  color: scheme.onTertiaryContainer,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: summary.pendingVerification,
                  label: 'Awaiting check',
                  color: scheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$value',
          style: JanMaangTypography.statNumber.copyWith(color: color),
        ),
        Text(
          label,
          style:
              JanMaangTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.category.icon,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.title,
                      style: JanMaangTypography.withWeight(
                        JanMaangTypography.bodyMd,
                        FontWeight.w600,
                      ).copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.demandCode} • ${entry.ward}',
                      style: JanMaangTypography.bodySm
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Insets.sm),
              Text(
                Formatters.rupeesCompact(entry.amount),
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.tabularNums,
                  FontWeight.w700,
                ).copyWith(color: scheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: Insets.md),
          Row(
            children: <Widget>[
              JmStatusChip.forStatus(entry.stage, dense: true),
              const SizedBox(width: Insets.sm),
              if (entry.verifiedByCitizens)
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.verified_user,
                          size: 14, color: scheme.onTertiaryContainer),
                      const SizedBox(width: Insets.xs),
                      Flexible(
                        child: Text(
                          'Verified by ${entry.verifierCount} citizens',
                          overflow: TextOverflow.ellipsis,
                          style: JanMaangTypography.bodySm
                              .copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text(
                    entry.department,
                    overflow: TextOverflow.ellipsis,
                    style: JanMaangTypography.bodySm
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              Text(
                Formatters.shortDate(entry.at),
                style: JanMaangTypography.bodySm
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
