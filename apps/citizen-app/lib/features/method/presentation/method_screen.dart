import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_colors.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../data/method_content.dart';
import '../domain/data_source.dart';

/// Methodology and data sources — the `/method` route.
///
/// Publishing the datasets, their licences, what each one feeds, what was
/// rejected and why, and what this build cannot compute. A ranking engine that
/// will not show its inputs is just an opinion with a number attached.
class MethodScreen extends StatelessWidget {
  const MethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: JmAppBar.task(title: 'Methodology & data'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.marginMobile,
          Insets.lg,
          Insets.marginMobile,
          Insets.xl,
        ),
        children: <Widget>[
          JmEnter(
            child: Text(
              'Where these numbers come from',
              style: JanMaangTypography.displayLgMobile
                  .copyWith(color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: Insets.sm),
          JmEnter(
            index: 1,
            child: Text(
              'Every dataset used or planned, with its licence and exactly what '
              'it feeds.',
              style: JanMaangTypography.bodyMd
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: Insets.lg),

          // The honesty banner comes first, not last.
          JmEnter(
            index: 2,
            child: JmCard(
              backgroundColor: scheme.secondaryFixed,
              borderColor: scheme.secondaryFixedDim,
              padding: const EdgeInsets.all(Insets.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline,
                      size: 18, color: scheme.onSecondaryFixed),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'This build ships a seeded corpus',
                          style: JanMaangTypography.withWeight(
                            JanMaangTypography.bodyMd,
                            FontWeight.w700,
                          ).copyWith(color: scheme.onSecondaryFixed),
                        ),
                        const SizedBox(height: Insets.xs),
                        Text(
                          MethodContent.corpusNote,
                          style: JanMaangTypography.bodySm
                              .copyWith(color: scheme.onSecondaryFixed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Insets.lg),

          _SectionTitle(title: 'Datasets in use'),
          const SizedBox(height: Insets.md),
          for (var i = 0; i < MethodContent.sources.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: JmEnter(
                index: 3 + i,
                child: _SourceCard(source: MethodContent.sources[i]),
              ),
            ),

          const SizedBox(height: Insets.lg),
          _SectionTitle(title: 'What this build cannot tell you'),
          const SizedBox(height: Insets.md),
          JmCard(
            backgroundColor: scheme.errorContainer,
            borderColor: scheme.errorContainer,
            padding: const EdgeInsets.all(Insets.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.timer_off_outlined,
                    size: 18, color: scheme.onErrorContainer),
                const SizedBox(width: Insets.sm),
                Expanded(
                  child: Text(
                    MethodContent.noSlaNote,
                    style: JanMaangTypography.bodySm
                        .copyWith(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),
          for (final landmine in MethodContent.landmines)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: _LandmineCard(landmine: landmine),
            ),

          const SizedBox(height: Insets.lg),
          _SectionTitle(title: 'Considered and rejected'),
          const SizedBox(height: Insets.sm),
          Text(
            'Listing what was left out, and why, is part of the method.',
            style: JanMaangTypography.bodySm
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.md),
          JmCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: Column(
              children: <Widget>[
                for (var i = 0; i < MethodContent.rejected.length; i++) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.md,
                      vertical: Insets.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 132,
                          child: Text(
                            MethodContent.rejected[i].name,
                            style: JanMaangTypography.withWeight(
                              JanMaangTypography.bodySm,
                              FontWeight.w600,
                            ).copyWith(color: scheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: Insets.sm),
                        Expanded(
                          child: Text(
                            MethodContent.rejected[i].reason,
                            style: JanMaangTypography.bodySm
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != MethodContent.rejected.length - 1)
                    Divider(color: scheme.outlineVariant, height: 1),
                ],
              ],
            ),
          ),

          const SizedBox(height: Insets.xl),
          Center(
            child: Text(
              'Base map © OpenStreetMap contributors, licensed ODbL.',
              textAlign: TextAlign.center,
              style: JanMaangTypography.bodySm
                  .copyWith(color: scheme.onSurfaceVariant, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: JanMaangTypography.headlineSm.copyWith(color: scheme.onSurface),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final DataSource source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final statusColour = switch (source.status) {
      SourceStatus.inUse => JanMaangColors.brandGreen,
      SourceStatus.notIngested => JanMaangColors.brandAmber,
      SourceStatus.optional => JanMaangColors.brandBlue,
    };

    return JmCard(
      radius: Corners.base,
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 24,
                child: Text(
                  '${source.index}',
                  style: JanMaangTypography.tabularNums
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: Text(
                  source.name,
                  style: JanMaangTypography.withWeight(
                    JanMaangTypography.bodyMd,
                    FontWeight.w600,
                  ).copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(width: Insets.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColour.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Text(
                  source.status.label,
                  style: JanMaangTypography.labelMd
                      .copyWith(color: statusColour, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  source.feeds,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                if (source.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Insets.xs),
                  Text(
                    source.note,
                    style: JanMaangTypography.bodySm.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: Insets.sm),
                Row(
                  children: <Widget>[
                    Icon(
                      source.isNonCommercial
                          ? Icons.gavel_outlined
                          : Icons.balance_outlined,
                      size: 13,
                      color: source.isNonCommercial
                          ? JanMaangColors.brandOrange
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Insets.xs),
                    Expanded(
                      child: Text(
                        source.licence,
                        style: JanMaangTypography.labelMd.copyWith(
                          color: source.isNonCommercial
                              ? JanMaangColors.brandOrange
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    JmPressable(
                      onTap: () => launchUrl(
                        Uri.parse(source.url),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Source',
                            style: JanMaangTypography.labelMd
                                .copyWith(color: scheme.secondary),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.open_in_new,
                              size: 12, color: scheme.secondary),
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

class _LandmineCard extends StatelessWidget {
  const _LandmineCard({required this.landmine});

  final Landmine landmine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      radius: Corners.base,
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: JanMaangColors.brandAmber),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Text(
                  landmine.title,
                  style: JanMaangTypography.withWeight(
                    JanMaangTypography.bodyMd,
                    FontWeight.w600,
                  ).copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          Text(
            landmine.body,
            style: JanMaangTypography.bodySm
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Insets.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(Corners.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'STATUS IN THIS BUILD',
                  style: JanMaangTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  landmine.status,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
