import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_colors.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/theme/motion.dart';

/// Inline loading banner — "Finding similar requests in this area…" — a
/// spinning indicator beside a body-sm line.
class JmInlineLoader extends StatelessWidget {
  const JmInlineLoader({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(width: Insets.sm + Insets.xs),
          Flexible(
            child: Text(
              message,
              style: JanMaangTypography.bodySm
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-surface loader for a screen that has nothing to show yet.
class JmLoader extends StatelessWidget {
  const JmLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHigh,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: Insets.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: JanMaangTypography.bodySm
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single skeleton block.
///
/// Used to hold the shape of content that is on its way, so a list does not
/// collapse and then jump when it arrives. The sweep is a slow, low-contrast
/// gradient rather than a bright shimmer — this is a loading state, not an
/// event. Holds still under reduce-motion.
class JmSkeleton extends StatefulWidget {
  const JmSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = Corners.sm,
  });

  /// A skeleton shaped like one card in a list.
  const JmSkeleton.card({super.key, this.height = 96})
      : width = double.infinity,
        radius = Corners.lg;

  final double? width;
  final double height;
  final double radius;

  @override
  State<JmSkeleton> createState() => _JmSkeletonState();
}

class _JmSkeletonState extends State<JmSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainer;
    final sweep = scheme.surfaceContainerLow;

    final box = SizedBox(width: widget.width, height: widget.height);

    if (Motion.reduced(context)) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: box,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 - 1;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: <Color>[base, sweep, base],
              stops: const <double>[0.1, 0.5, 0.9],
            ),
          ),
          child: box,
        );
      },
    );
  }
}

/// A stack of card skeletons, for a list that has not resolved yet.
class JmSkeletonList extends StatelessWidget {
  const JmSkeletonList({super.key, this.count = 3, this.itemHeight = 96});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: Column(
        children: <Widget>[
          for (var i = 0; i < count; i++) ...<Widget>[
            JmSkeleton.card(height: itemHeight),
            if (i != count - 1) const SizedBox(height: Insets.sm),
          ],
        ],
      ),
    );
  }
}

/// Empty state — a tinted brand medallion, a title, a supporting line and,
/// where there is one, the action that would fill it.
class JmEmptyState extends StatelessWidget {
  const JmEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: Insets.xl - Insets.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Medallion(
              icon: icon,
              background: scheme.primaryFixed,
              foreground: scheme.onPrimaryFixedVariant,
            ),
            const SizedBox(height: Insets.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: Insets.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: JanMaangTypography.bodySm
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: Insets.lg),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, Hit.control),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state. Shows the human sentence carried by a [Failure] and offers a
/// retry; anything else gets the generic line.
///
/// Red appears only in the medallion. The rest of the component stays calm —
/// a failed request is not an emergency, and shouting about it makes a citizen
/// think they broke something.
class JmErrorView extends StatelessWidget {
  const JmErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title = 'Something went wrong',
  });

  final Object error;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final message = error is Failure
        ? (error as Failure).message
        : "We couldn't load this information right now.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Medallion(
              icon: Icons.cloud_off_rounded,
              background: brightness == Brightness.light
                  ? JmSemantic.criticalTint
                  : JmSemantic.critical.withValues(alpha: 0.20),
              foreground: brightness == Brightness.light
                  ? JmSemantic.onCriticalTint
                  : Color.lerp(
                      JmSemantic.critical, const Color(0xFFFFFFFF), 0.62)!,
            ),
            const SizedBox(height: Insets.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: Insets.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: JanMaangTypography.bodySm
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: Insets.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(170, Hit.min),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The 68px tinted circle that heads every empty and error state, with a
/// hairline ring so it holds its shape on a white card.
class _Medallion extends StatelessWidget {
  const _Medallion({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: foreground.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, size: 30, color: foreground),
    );
  }
}
