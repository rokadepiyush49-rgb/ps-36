import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_colors.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../core/theme/motion.dart';
import '../../../shared/widgets/jm_logo.dart';

/// The first three seconds of the product.
///
/// A staged reveal of the brand mark, then the wordmark, then the five colour
/// bars that run under the logo, then the tagline, then the BRICS line — each
/// beat overlapping the one before so the sequence reads as one movement
/// rather than five separate fades. The whole thing then dissolves into the
/// landing screen.
///
/// Three things this screen is careful about:
///
/// * **It is a loading screen, not a gate.** The timeline runs while the auth
///   stream resolves in the background; if a citizen is already signed in they
///   land on Home, otherwise on the landing page. Nobody waits on it twice —
///   it only ever runs at cold start.
/// * **Reduce-motion is honoured properly.** Not by speeding the animation up,
///   but by painting the finished composition immediately and moving on after
///   a beat, which is what someone who asked for less motion actually wants.
/// * **Feedback is haptic, not audible.** Flutter can play the platform's own
///   click through [SystemSound] without a package, and a light impact at the
///   two beats that matter reads as "something happened" without needing an
///   audio dependency or shipping a sound file. A real chime would need an
///   audio plugin — see the note on [_playBeat].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the full sequence runs before handing over.
  static const duration = Duration(milliseconds: 3400);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.duration,
  );

  Timer? _handoff;
  bool _leaving = false;

  /// Beats, as fractions of the total duration. Keeping them in one table is
  /// what lets the overlaps stay deliberate instead of accidental.
  static const _markIn = Interval(0.00, 0.28, curve: Curves.easeOutCubic);
  static const _wordIn = Interval(0.16, 0.40, curve: Curves.easeOutCubic);
  static const _barsIn = Interval(0.26, 0.52, curve: Curves.easeOutCubic);
  static const _taglineIn = Interval(0.38, 0.58, curve: Curves.easeOut);
  static const _bricsIn = Interval(0.55, 0.76, curve: Curves.easeOutCubic);
  static const _fadeOut = Interval(0.88, 1.00, curve: Curves.easeIn);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (Motion.reduced(context)) {
      _controller.value = 0.86; // the composition, settled, without the exit
      _handoff = Timer(const Duration(milliseconds: 600), _go);
      return;
    }

    _controller.forward();
    _controller.addListener(_onTick);
    _handoff = Timer(SplashScreen.duration, _go);
  }

  bool _beatOne = false;
  bool _beatTwo = false;

  void _onTick() {
    // Haptics fired from the timeline rather than from timers, so they stay in
    // sync if the animation is ever slowed or scrubbed.
    if (!_beatOne && _controller.value >= 0.28) {
      _beatOne = true;
      _playBeat(light: true);
    }
    if (!_beatTwo && _controller.value >= 0.60) {
      _beatTwo = true;
      _playBeat(light: false);
    }
  }

  /// Platform feedback for a beat in the sequence.
  ///
  /// [SystemSound] and [HapticFeedback] are part of Flutter itself, so this
  /// costs nothing in dependencies. Shipping an actual audio logo would mean
  /// adding an audio plugin and a sound file, and would need a mute control —
  /// worth doing deliberately rather than as a side effect of a splash screen.
  void _playBeat({required bool light}) {
    if (light) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _go() {
    if (!mounted || _leaving) return;
    _leaving = true;
    // Hands back whatever the citizen was actually opening — a shared demand
    // link, a bookmark, or the landing page on a plain cold start. The
    // router's redirect still has the final say: a signed-in citizen going to
    // an auth route ends up on Home.
    context.go(SplashGate.release());
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final mark = _markIn.transform(t);
          final word = _wordIn.transform(t);
          final bars = _barsIn.transform(t);
          final tagline = _taglineIn.transform(t);
          final brics = _bricsIn.transform(t);
          final exit = 1 - _fadeOut.transform(t);

          return Opacity(
            opacity: exit,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Insets.lg),
                // SizedBox.expand, not a bare Column: Scaffold lays its body
                // out under *loose* constraints, so a shrink-wrapping Column
                // takes the width of its widest child and sits flush left.
                // Forcing the full width is what actually centres this.
                child: SizedBox.expand(
                  child: Column(
                    children: <Widget>[
                      const Spacer(flex: 3),

                      // The mark rises and settles.
                      Opacity(
                        opacity: mark,
                        child: Transform.scale(
                          scale: 0.72 + 0.28 * mark,
                          child: JmLogo.mark(size: 132),
                        ),
                      ),

                      const SizedBox(height: Insets.lg),

                      // Wordmark. Set in Latin rather than Devanagari because the
                      // bundled faces do not carry a Devanagari glyph set — the
                      // bilingual lockup lives in the artwork, not in live text.
                      Opacity(
                        opacity: word,
                        child: Transform.translate(
                          offset: Offset(0, 14 * (1 - word)),
                          child: Text(
                            'JANMAANG',
                            style: JanMaangTypography.displayLgMobile.copyWith(
                              color: scheme.primary,
                              fontSize: 30,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: Insets.md),

                      // The five bars from under the wordmark, drawing outward
                      // from the centre in the order they appear in the logo.
                      _ColourBars(progress: bars),

                      const SizedBox(height: Insets.md + Insets.xs),

                      Opacity(
                        opacity: tagline,
                        child: Text(
                          JmLogo.tagline,
                          textAlign: TextAlign.center,
                          style: JanMaangTypography.bodySm.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // The BRICS line, last and quietest.
                      Opacity(
                        opacity: brics,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - brics)),
                          child: const _BricsMark(),
                        ),
                      ),

                      const SizedBox(height: Insets.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The five logo bars, expanding from the centre outward.
///
/// Each bar starts at the midpoint of the row and grows to its full width on a
/// slight stagger, so the group reads as one gesture opening rather than five
/// rectangles appearing.
class _ColourBars extends StatelessWidget {
  const _ColourBars({required this.progress});

  final double progress;

  static const _colours = <Color>[
    JanMaangColors.brandGreen,
    JanMaangColors.brandBlue,
    JanMaangColors.brandOrange,
    JanMaangColors.brandRed,
    JanMaangColors.brandAmber,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 5,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < _colours.length; i++) ...<Widget>[
            if (i != 0) const SizedBox(width: 4),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: _stagger(i),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: _colours[i],
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Distance from the centre of the row decides how late a bar starts.
  double _stagger(int index) {
    final distance = (index - 2).abs() / 2; // 0 at centre, 1 at the ends
    final start = distance * 0.35;
    if (progress <= start) return 0.0;
    final v = (progress - start) / (1 - start);
    return v > 1.0 ? 1.0 : v;
  }
}

/// The BRICS attribution that sits under the mark in the brand artwork.
class _BricsMark extends StatelessWidget {
  const _BricsMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 44,
          height: 1,
          color: scheme.outlineVariant,
        ),
        const SizedBox(height: Insets.sm + Insets.xs),
        Text(
          'BRICS',
          style: JanMaangTypography.labelMd.copyWith(
            color: scheme.primary,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
