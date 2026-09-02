import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_colors.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../../../shared/widgets/jm_logo.dart';
import '../../../shared/widgets/jm_surfaces.dart';

/// The landing page. One screen, no scrolling.
///
/// A landing page that scrolls is a landing page that buries its own call to
/// action, so everything here is sized to fit the viewport it is given. The
/// whole composition is measured at its natural height and scaled down to fit
/// when the screen is short — a uniform scale keeps the proportions and the
/// hierarchy intact, which is what would break if each block were squeezed
/// independently.
///
/// Content arrives in a short stagger, top to bottom, so the page assembles
/// itself rather than appearing all at once.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _steps = <(IconData, String, String, JmTint)>[
    (Icons.mic_rounded, 'You speak', 'In your own language', JmTint.navy),
    (Icons.auto_awesome_rounded, 'We analyse', 'AI structures it', JmTint.blue),
    (Icons.account_balance_rounded, 'Funds follow', 'Budget is allocated',
        JmTint.green),
    (Icons.verified_rounded, 'You verify', 'Citizens confirm it', JmTint.amber),
  ];

  /// Widest the column is allowed to get. Past this a landing page stops
  /// looking composed and starts looking stretched.
  static const _maxContentWidth = 460.0;

  static const _recentlyFixed = <String>[
    'Streetlights',
    'Handpumps',
    'Drains',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.lg,
            Insets.md,
            Insets.lg,
            Insets.md,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive in both directions. Horizontally the column is
              // capped and centred, because a landing page set edge to edge on
              // a tablet reads as a stretched phone screen rather than a
              // designed one. Vertically the whole composition is measured at
              // its natural height and scaled down as a single piece when the
              // viewport is short — scaling uniformly keeps the proportions and
              // the hierarchy, which is exactly what breaks if each block is
              // squeezed on its own.
              final contentWidth = constraints.maxWidth > _maxContentWidth
                  ? _maxContentWidth
                  : constraints.maxWidth;

              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        JmEnter(child: const _Brand()),
                        const SizedBox(height: Insets.lg),

                        JmEnter(
                          index: 1,
                          child: const JmDisplayHeading(
                            lead: 'Civic action',
                            emphasis: 'starts here.',
                          ),
                        ),
                        const SizedBox(height: Insets.sm + Insets.xs),
                        JmEnter(
                          index: 2,
                          child: Text(
                            'No forms. No queues. Just your voice — reported '
                            'once, then followed all the way to a fix.',
                            style: JanMaangTypography.bodyMd
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),

                        const SizedBox(height: Insets.lg),

                        // The four steps, as a grid rather than a column: the
                        // vertical explainer was the single tallest thing on
                        // this page and the one that forced it to scroll.
                        const _Steps(),

                        const SizedBox(height: Insets.md),
                        JmEnter(index: 7, child: const _ImpactStrip()),

                        const SizedBox(height: Insets.md),
                        JmEnter(index: 8, child: const _RecentlyFixed()),

                        const SizedBox(height: Insets.lg),
                        JmEnter(
                          index: 9,
                          child: _ArrowCta(
                            label: "Tell us what's wrong",
                            hint: 'Voice or text · Available 24/7',
                            onTap: () =>
                                context.goNamed(AppRoute.login.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The mark beside the wordmark, with the tagline underneath.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        JmLogo.mark(size: 52),
        const SizedBox(width: Insets.sm + Insets.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'JANMAANG',
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.titleLg,
                  FontWeight.w700,
                ).copyWith(color: scheme.primary, letterSpacing: 2.4),
              ),
              Text(
                JmLogo.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JanMaangTypography.caption
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The four-step explainer, two across.
class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: <Widget>[
        for (var row = 0; row < 2; row++) ...<Widget>[
          if (row != 0) const SizedBox(height: Insets.sm + Insets.xs),
          Row(
            // Not CrossAxisAlignment.stretch: the cross axis here is vertical
            // and this subtree is measured under unbounded height, where
            // stretch has nothing to stretch to. The tiles carry an explicit
            // height instead, which also guarantees the pair line up.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var col = 0; col < 2; col++) ...<Widget>[
                if (col != 0) const SizedBox(width: Insets.sm + Insets.xs),
                Expanded(
                  // Each cell carries its own entrance index, so the grid
                  // fills in one tile at a time — first, second, third,
                  // fourth — instead of the whole block arriving at once.
                  child: JmEnter(
                    index: 3 + row * 2 + col,
                    child: _StepTile(
                      number: row * 2 + col + 1,
                      step: OnboardingScreen._steps[row * 2 + col],
                      brightness: brightness,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.step,
    required this.brightness,
  });

  /// Fixed so a row of tiles lines up without asking the layout for an
  /// intrinsic height it cannot supply here.
  static const _tileHeight = 116.0;

  final int number;
  final (IconData, String, String, JmTint) step;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body, tint) = step;
    final fg = tint.foreground(brightness);

    return Container(
      height: _tileHeight,
      padding: const EdgeInsets.all(Insets.md - 2),
      decoration: BoxDecoration(
        color: tint.background(brightness),
        borderRadius: BorderRadius.circular(Corners.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tint.well(brightness),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Icon(icon, size: 17, color: fg),
              ),
              const Spacer(),
              Text(
                '$number',
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.bodySm,
                  FontWeight.w700,
                ).copyWith(color: fg.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm + Insets.xs),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: JanMaangTypography.withWeight(
              JanMaangTypography.bodyMd,
              FontWeight.w700,
            ).copyWith(color: fg),
          ),
          Text(
            body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: JanMaangTypography.bodySm
                .copyWith(color: fg.withValues(alpha: 0.82)),
          ),
        ],
      ),
    );
  }
}

/// The pilot-impact figure, compressed into a single navy strip.
class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.md - 2,
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(Corners.lg),
        boxShadow: Shadows.level2,
      ),
      child: Row(
        children: <Widget>[
          Text(
            '95%',
            style: JanMaangTypography.statNumber
                .copyWith(color: scheme.onPrimary),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'PILOT IMPACT',
                  style: JanMaangTypography.labelMd
                      .copyWith(color: scheme.primaryFixedDim),
                ),
                Text(
                  'fewer pending demands in Yadgir',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.primaryFixed),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up_rounded,
            size: 26,
            color: scheme.onPrimary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// The proof line: three things that actually got fixed, as chips.
class _RecentlyFixed extends StatelessWidget {
  const _RecentlyFixed();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return Row(
      children: <Widget>[
        Icon(Icons.check_circle_rounded, size: 16, color: JmSemantic.success),
        const SizedBox(width: Insets.sm - 2),
        Text(
          'Recently fixed',
          style: JanMaangTypography.withWeight(
            JanMaangTypography.bodySm,
            FontWeight.w600,
          ).copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: Insets.sm),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: Insets.xs + 2,
            runSpacing: Insets.xs,
            children: <Widget>[
              for (final label in OnboardingScreen._recentlyFixed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.sm + 2,
                    vertical: Insets.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: JmTint.green.background(brightness),
                    borderRadius: BorderRadius.circular(Corners.pill),
                  ),
                  child: Text(
                    label,
                    style: JanMaangTypography.labelMd.copyWith(
                      color: JmTint.green.foreground(brightness),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}


/// The landing page's call to action: a dark circle with an arrow, and the
/// words underneath it.
///
/// A full-width filled button was competing with the impact strip directly
/// above it — two heavy horizontal slabs stacked. A circle reads as a single
/// point to aim at, and moving the label below it lets the button be large
/// without being wide.
class _ArrowCta extends StatefulWidget {
  const _ArrowCta({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  State<_ArrowCta> createState() => _ArrowCtaState();
}

class _ArrowCtaState extends State<_ArrowCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nudge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool _pressed = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!Motion.reduced(context)) _nudge.repeat();
  }

  @override
  void dispose() {
    _nudge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = Motion.reduced(context);

    return Semantics(
      button: true,
      label: '${widget.label}. ${widget.hint}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: reduced || !_pressed ? 1.0 : 0.94,
              duration: Motion.fast,
              curve: Motion.curve,
              child: AnimatedBuilder(
                animation: _nudge,
                builder: (context, child) {
                  // The arrow drifts a couple of pixels forward and back —
                  // enough to read as "this way", not enough to fidget.
                  final t = reduced
                      ? 0.0
                      : Curves.easeInOut.transform(
                          (_nudge.value * 2 <= 1
                              ? _nudge.value * 2
                              : 2 - _nudge.value * 2),
                        );
                  return Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: Shadows.level2,
                    ),
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(3 * t, 0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 28,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: Insets.md - 2),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: JanMaangTypography.withWeight(
              JanMaangTypography.bodyLg,
              FontWeight.w700,
            ).copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            widget.hint,
            textAlign: TextAlign.center,
            style: JanMaangTypography.bodySm
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
