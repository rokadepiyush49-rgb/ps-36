import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// One factor on the "Why is this ranked #2?" card: a label, a right-aligned
/// tabular score, and a thin track filled to that score.
class JmMetricBar extends StatelessWidget {
  const JmMetricBar({
    super.key,
    required this.label,
    required this.score,
    this.explanation = '',
    this.animate = true,
  });

  final String label;
  final int score;
  final String explanation;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = (score.clamp(0, 100)) / 100;

    return Semantics(
      label: '$label, score $score out of 100',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              Text(
                '$score',
                style: JanMaangTypography.tabularNums
                    .copyWith(color: scheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: Insets.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(Corners.sm),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: animate
                  ? const Duration(milliseconds: 650)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ),
          if (explanation.isNotEmpty) ...<Widget>[
            const SizedBox(height: Insets.xs),
            Text(
              explanation,
              style: JanMaangTypography.bodySm
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
