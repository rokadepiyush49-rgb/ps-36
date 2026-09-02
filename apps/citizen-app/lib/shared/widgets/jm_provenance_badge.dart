import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import '../models/provenance.dart';

/// The small, calm "where this figure came from" marker.
///
/// Deliberately understated — the brief asks for professional, not alarming.
/// It reads as metadata, and tapping it explains the dataset and its licence
/// rather than hiding the caveat in a footnote.
class JmProvenanceBadge extends StatelessWidget {
  const JmProvenanceBadge({
    super.key,
    required this.stamp,
    this.compact = false,
  });

  final ProvenanceStamp stamp;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Data provenance: ${stamp.line}',
      button: true,
      child: InkWell(
        onTap: () => _explain(context),
        borderRadius: BorderRadius.circular(Corners.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 2 : Insets.xs,
            vertical: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                stamp.provenance.isSeeded
                    ? Icons.dataset_outlined
                    : Icons.person_pin_circle_outlined,
                size: compact ? 11 : 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Insets.xs),
              Flexible(
                child: Text(
                  stamp.line,
                  overflow: TextOverflow.ellipsis,
                  style: JanMaangTypography.labelMd.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: compact ? 10 : 11,
                    letterSpacing: 0.02 * 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _explain(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.lg,
          0,
          Insets.lg,
          Insets.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              stamp.provenance.shortLabel,
              style:
                  JanMaangTypography.headlineSm.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: Insets.sm),
            Text(
              stamp.provenance.description,
              style: JanMaangTypography.bodyMd
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: Insets.md),
            _Row(label: 'Source', value: stamp.provenance.sourceName),
            _Row(label: 'Licence', value: stamp.provenance.licence),
            _Row(label: 'Location', value: stamp.precision.label),
            if (stamp.provenance.isSeeded) ...<Widget>[
              const SizedBox(height: Insets.md),
              Container(
                padding: const EdgeInsets.all(Insets.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(Corners.base),
                ),
                child: Text(
                  'This record is seeded and labelled. It is realistic, not '
                  'real: figures are modelled from published distributions and '
                  'perturbed per unit, and the coordinate is a hand-placed '
                  'centroid rather than a surveyed point.',
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              label.toUpperCase(),
              style: JanMaangTypography.labelMd
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  JanMaangTypography.bodySm.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
