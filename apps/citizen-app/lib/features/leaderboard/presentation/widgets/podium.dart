import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../domain/contributor.dart';

/// Top three, on a podium.
///
/// Ordered 2 · 1 · 3 across the screen so the winner sits centre and tallest,
/// which reads instantly without needing to parse the rank numbers.
class Podium extends StatelessWidget {
  const Podium({super.key, required this.top});

  final List<Contributor> top;

  @override
  Widget build(BuildContext context) {
    if (top.isEmpty) return const SizedBox.shrink();

    final first = top.first;
    final second = top.length > 1 ? top[1] : null;
    final third = top.length > 2 ? top[2] : null;

    return SizedBox(
      height: 210,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: second == null
                ? const SizedBox.shrink()
                : _Plinth(contributor: second, height: 96, delay: 2),
          ),
          const SizedBox(width: Insets.sm),
          Expanded(child: _Plinth(contributor: first, height: 132, delay: 0)),
          const SizedBox(width: Insets.sm),
          Expanded(
            child: third == null
                ? const SizedBox.shrink()
                : _Plinth(contributor: third, height: 74, delay: 3),
          ),
        ],
      ),
    );
  }
}

class _Plinth extends StatelessWidget {
  const _Plinth({
    required this.contributor,
    required this.height,
    required this.delay,
  });

  final Contributor contributor;
  final double height;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFirst = contributor.rank == 1;

    final medal = switch (contributor.rank) {
      1 => JanMaangColors.brandAmber,
      2 => const Color(0xFFA8B2BF),
      _ => JanMaangColors.brandOrange,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isFirst)
          Icon(Icons.emoji_events, size: 22, color: medal)
        else
          const SizedBox(height: 22),
        const SizedBox(height: Insets.xs),

        Container(
          width: isFirst ? 60 : 48,
          height: isFirst ? 60 : 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: medal.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: medal, width: 2),
          ),
          child: Text(
            contributor.initials,
            style: JanMaangTypography.withWeight(
              JanMaangTypography.titleLg,
              FontWeight.w700,
            ).copyWith(
              color: scheme.onSurface,
              fontSize: isFirst ? 20 : 16,
            ),
          ),
        ),
        const SizedBox(height: Insets.sm),

        Text(
          contributor.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: JanMaangTypography.withWeight(
            JanMaangTypography.bodySm,
            FontWeight.w600,
          ).copyWith(color: scheme.onSurface),
        ),
        Text(
          contributor.ward,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: JanMaangTypography.labelMd
              .copyWith(color: scheme.onSurfaceVariant, fontSize: 10),
        ),
        const SizedBox(height: Insets.sm),

        // The plinth grows into place, which is the one moment on this screen
        // where a flourish is warranted.
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Motion.reduced(context)
              ? Duration.zero
              : Motion.slow + Motion.stagger * delay,
          curve: Motion.enter,
          builder: (context, t, child) => SizedBox(
            height: height * t,
            width: double.infinity,
            child: child,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  medal.withValues(alpha: 0.22),
                  medal.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Corners.base),
              ),
              border: Border.all(color: medal.withValues(alpha: 0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: Insets.sm),
              child: Column(
                children: <Widget>[
                  Text(
                    '#${contributor.rank}',
                    style: JanMaangTypography.withWeight(
                      JanMaangTypography.titleLg,
                      FontWeight.w700,
                    ).copyWith(color: scheme.onSurface),
                  ),
                  JmAnimatedCount(
                    value: contributor.impactScore,
                    builder: (context, value) => Text(
                      '$value pts',
                      style: JanMaangTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
