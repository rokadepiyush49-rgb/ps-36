import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The motion system.
///
/// One vocabulary of durations and curves so every transition in the app feels
/// like it came from the same hand. Motion here is for orientation — telling
/// you where something came from and what just changed — never decoration.
abstract final class Motion {
  /// Hover, press, colour and small state flips.
  static const fast = Duration(milliseconds: 140);

  /// Indicator slides, chip selection, card entrance.
  static const medium = Duration(milliseconds: 260);

  /// Page transitions and bottom sheets.
  static const slow = Duration(milliseconds: 360);

  /// Counters and progress bars filling.
  static const counter = Duration(milliseconds: 900);

  /// Default easing: quick to leave, gentle to arrive.
  static const curve = Curves.easeOutCubic;

  /// For anything that should feel physical — pressed buttons, selected pins.
  static const spring = Curves.easeOutBack;

  /// Emphasis for elements entering the screen.
  static const enter = Curves.easeOutQuart;

  /// Stagger between siblings in a list entrance.
  static const stagger = Duration(milliseconds: 60);

  /// Whether the platform asked us to keep still.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Fade-and-rise entrance, staggered by [index].
///
/// The workhorse for dashboard cards, list rows and stat tiles. Respects
/// reduce-motion by rendering the child immediately at rest.
class JmEnter extends StatefulWidget {
  const JmEnter({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 16,
    this.duration = Motion.medium,
  });

  final Widget child;
  final int index;

  /// How far the child rises, in logical pixels.
  final double offset;
  final Duration duration;

  @override
  State<JmEnter> createState() => _JmEnterState();
}

class _JmEnterState extends State<JmEnter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  /// Held so it can be cancelled: a row scrolled out of the list before its
  /// turn to animate would otherwise leave a timer running against a disposed
  /// widget.
  Timer? _stagger;

  @override
  void initState() {
    super.initState();
    final delay = Motion.stagger * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _stagger = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _stagger?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;

    final animation = CurvedAnimation(parent: _controller, curve: Motion.enter);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - animation.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Counts up to [value] when it first becomes visible.
///
/// Used for the impact figures on Home. The number is announced to screen
/// readers at its final value rather than mid-count.
class JmAnimatedCount extends StatelessWidget {
  const JmAnimatedCount({
    super.key,
    required this.value,
    required this.builder,
    this.duration = Motion.counter,
  });

  final int value;
  final Widget Function(BuildContext context, int value) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return builder(context, value);

    return Semantics(
      liveRegion: false,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.toDouble()),
        duration: duration,
        curve: Motion.curve,
        builder: (context, animated, _) =>
            ExcludeSemantics(child: builder(context, animated.round())),
      ),
    );
  }
}

/// Press feedback: a small compression on tap-down, released on tap-up.
///
/// The brief asks for this on every important control, and explicitly asks it
/// not to bounce — hence a short ease rather than a spring overshoot.
class JmPressable extends StatefulWidget {
  const JmPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.hoverScale = 1.01,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double hoverScale;
  final BorderRadius? borderRadius;

  @override
  State<JmPressable> createState() => _JmPressableState();
}

class _JmPressableState extends State<JmPressable> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final scale = !enabled
        ? 1.0
        : _pressed
            ? widget.pressedScale
            : (_hovered ? widget.hoverScale : 1.0);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: Motion.reduced(context) ? 1.0 : scale,
          duration: Motion.fast,
          curve: Motion.curve,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Page transition used by every pushed route: a short fade with a slight rise.
///
/// Deliberately restrained — the design system's whole argument is that this is
/// government software people trust, not an app that shows off.
class JmPageTransition extends CustomTransitionPage<void> {
  JmPageTransition({required super.child, super.key})
      : super(
          transitionDuration: Motion.slow,
          reverseTransitionDuration: Motion.medium,
          transitionsBuilder: (context, animation, secondary, child) {
            if (Motion.reduced(context)) return child;

            final curved =
                CurvedAnimation(parent: animation, curve: Motion.enter);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
